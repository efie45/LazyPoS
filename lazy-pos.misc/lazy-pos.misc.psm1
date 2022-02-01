using namespace System

function Assert-PSVersion {
    #TODO: Docs
    #TODO: Unit Tests
    <#
    .SYNOPSIS
    Validate the PowerShell version

    .DESCRIPTION
    To be used in situations where the [Microsoft Requires ]
    #>
    [OutputType([bool])]
    [Cmdletbinding()]
    Param(

        # Minimum version to check against. Can provide
        [Parameter(Mandatory)]
        [string]$MinimumVersion,

        # Current version defaults to $PSVersionTable.PSVersion
        [Parameter()]
        [Version]$CurrentVersion = $PSVersionTable.PSVersion,

        # Throw an error if version doesn't meet requirements
        [Parameter()]
        [switch]$ThrowOnFalse
    )
    Process {
        [Version]$min = $MinimumVersion
        if ($CurrentVersion -lt $min) {
            if ($ThrowOnFalse) {
                throw "PSVersion must be at least $min to use this function"
            }
            return $false
        }
        return $true
    }
}

function ConvertTo-Version {
    <#
    .SYNOPSIS
    Converts a value to a .NET [Version] object

    .DESCRIPTION
    Converts a string, int, or decimal value to a .NET System.Version type.

    Version.Parse() is often sufficient but it doesn't properly handle some situations such as single-digit values.
    Single digit values will be given a 'minor' version number of 0 to be compatible with .NET version type requirements.

    Version values in .NET are in the following format:
      {major}.{minor}.{build}.{revision}

    If only major version is provided a Version will be produced with value {major}.0
    For example, providing '1' will give you a version with the following properties:

    Major  Minor  Build  Revision
    -----  -----  -----  --------
    1      0      -1     -1

    .EXAMPLE


    .NOTES
    Note that a Version type that doesn't specify a build or revision is considered 'less than'
    a Version type that does specify these values. For example:

    >> [Version]'1.0' -lt [Version]'1.0.0'
    >> True

    See the Microsoft Docs for more details:
    https://docs.microsoft.com/en-us/dotnet/api/system.version

    #>
    [OutputType([Version])]
    [Cmdletbinding()]
    param(
        # Value to be parsed into a Version type
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Value
    )
    Process {
        if ($Value -match '[^\d\.]') {
            throw [ArgumentException] "Version can only contain chars 0-9 and '.'"
        }

        $split = $Value -split '\.'
        $major, $minor, $build, $revision = $split

        if ($split.Count -gt 4) {
            'Version can only have a maximum of 4 version numbers. ' +
            'Version will be truncated to format {major}.{minor}.{build}.{revision}' |
                Write-Warning
            $revision = $revision[0]
        }

        $major, $minor, $build, $revision | ForEach-Object {
            if ([bigint]$_ -gt [int32]::MaxValue) {
                $lengthError = "Part of version string '$_' exceeded maximum int32 value of $([int32]::MaxValue). " +
                'This version cannot be converted to a .NET Version type'
                throw [ArgumentException] $lengthError
            }
        }
        if (-not $minor) {
            'No minor version provided. Minor version required for .NET version type. Minor version ' +
            'will be set to 0.' |
                Write-Warning
            $minor = 0
        }
        return [Version]"$major.$minor$($build ? ".$build" : '')$($revision ? ".$revision" : '')"
    }
}

function ConvertTo-PSSyntax {
    #TODO: Documentation
    #TODO: Unit Tests
    <#
    .DESCRIPTION
    Converts JSON to the syntax you would use in a PowerShell script to create a PSObject or Hashtable.
    Useful for making mock objects for unit tests while you're debugging through your scripts.

    .EXAMPLE
    You're debugging your script and have an object you would like to capture and run tests on.
    You could export as JSON, keep in a file and use as a resource but if you want to use an object inline you can use
      this function like this:

    $myObj | ConvertTo-PSSyntax
    .NOTES
    Not the most efficient way of doing this, but usually only used for small objects when creating tests.
    Could use refactoring for efficiency and additional edge cases if being used for different purposes.
    #>
    [Cmdletbinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Runtime.Serialization.ISerializable]$InputObject
    )
    Process {

        $json = ($InputObject | Test-Json -ErrorAction SilentlyContinue) ?
        ($InputObject | ConvertFrom-Json | ConvertTo-Json -Depth 100) :
        ($InputObject | ConvertTo-Json -Depth 100)

        $json |
            ForEach-Object { $_ -replace ",(?=`n)", '' } |
            ForEach-Object { $_ -replace "{(?=`n)", '@{' } |
            ForEach-Object { $_ -replace "\[(?=`n)", '@(' } |
            ForEach-Object { $_ -replace "](?=`n)", ')' } |
            ForEach-Object { $_ -replace ':', ' =' } |
            Write-Output
    }
}

function Invoke-SortVSCodeSetting {
    #TODO: Documentation
    #TODO: Unit Tests
    <#
    .SYNOPSIS
    Alphabetically sort VSCode's settings json file in ascending or descending order

    #>
    [Output([Void])]
    [Cmdletbinding()]
    Param(
        [Parameter()]
        [ValidateScript( { Test-Path -Path $_ })]
        $SettingsPath,

        [Parameter()]
        [switch]$Descending
    )
    Process {
        Assert-PSVersion 7
        $SettingsPath ??= $(
            $warning = 'No SettingsPath was provided. Using default path for your operating system of '
            if ($IsMacOS) { "$HOME/Library/Application Support/Code/User/settings.json" }
            if ($IsWindows) { "$env:APPDATA\Code\User\settings.json" }
            if ($IsLinux) { "$HOME/.config/Code/User/settings.json" }
        )
        if ($warning) { $warning + $SettingsPath | Write-Warning }
        $sorted = [PSCustomObject]::new()
        Get-Content $SettingsPath | ConvertFrom-Json -PipelineVariable json |
            Get-Member -Type  NoteProperty |
            Sort-Object Name -Descending:$Descending |
            ForEach-Object {
                $addMember = @{
                    InputObject = $sorted
                    Type        = 'NoteProperty'
                    Name        = $_.Name
                    Value       = $json.$($_.Name)
                }
                Add-Member @addMember
            }
        $sorted | ConvertTo-Json -Depth 100 | Out-File $SettingsPath -Force
    }
}

function Get-RandomChar {
    #TODO: Documentation
    #TODO: Unit Tests
    [Output([char])]
    [Cmdletbinding()]
    Param(
        [Alias('Upper')]
        [Parameter(ParameterSetName = 'Uppercase')]
        [switch] $Uppercase,

        [Alias('Lower')]
        [Parameter(ParameterSetName = 'Lowercase')]
        [switch] $Lowercase
    )
    Begin {
        $alphaASCIIRangeUppercase = (65..90)
        $alphaASCIIRangeLowercase = (97..122)
    }
    Process {
        if ($Uppercase) {
            return $alphaASCIIRangeUppercase | Get-Random | ForEach-Object { [char]$_ }
        }
        if ($Lowercase) {
            return $alphaASCIIRangeLowercase | Get-Random | ForEach-Object { [char]$_ }
        }
    }
}

function Invoke-RandomizeClipboard {
    #TODO: Documentation
    #TODO: Unit Tests
    [OutputType([Void])]
    [Alias('cliprand')]
    [Cmdletbinding()]
    Param()
    $clipboardContent = Get-Clipboard
    $randomized = New-Object -TypeName 'char[]' -ArgumentList $clipboardContent.Length
    $i = 0
    $clipboardContent.ToCharArray() | ForEach-Object {
        switch -Regex -CaseSensitive ($_) {
            '[A-Z]' {
                $randomized[$i] = Get-RandomChar -Upper
                break
            }
            '[a-z]' {
                $randomized[$i] = Get-RandomChar -Lower
                break
            }
            '[0-9]' {
                $randomized[$i] = [char][string](Get-Random -Minimum 0 -Maximum 9)
                break
            }
            default {
                $randomized[$i] = $_
                break
            }
        }
        $i++
    }
    Write-Verbose "Copied randomized value to clipboard: $randomized"
    [string]::new($randomized) | Set-Clipboard
}