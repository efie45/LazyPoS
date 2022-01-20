function Assert-PSVersion {
    #TODO: Documentation
    #TODO: Unit Tests
    <#
    .SYNOPSIS
    Validate the PowerShell version
    #>
    [Cmdletbinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$MinimumVersion,

        [Parameter()]
        [Version]$CurrentVersion = $PSVersionTable.PSVersion
    )
    Process {
        [Version]$min = $MinimumVersion.contains('.') ? $MinimumVersion : $MinimumVersion + '.0'
        if ($CurrentVersion -lt $min) {
            throw "PSVersion must be at least $min to use this function"
        }
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

    $myObj | ConvertTo-JSON

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

function Set-ClipboardWithNewGuid {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    [Alias('guid')]
    Param()
    New-Guid | Set-Clipboard
}

function Get-RandomChar {
    #TODO: Documentation
    #TODO: Unit Tests
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
    [OutputType([System.Void])]
    [Alias('cliprand')]
    [Cmdletbinding()]
    Param()
    $clipboardContent = Get-Clipboard
    $randomized = New-Object -TypeName 'char[]' -ArgumentList $clipboardContent.Length
    $clipboardContent.ToCharArray() | ForEach-Object { $i = 0 } {
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
    [string]::new($randomized) | Set-Clipboard
}

Export-ModuleMember -Function (
    'Set-ClipboardWithNewGuid',
    'Get-RandomChar',
    'Invoke-RandomizeClipboard',
    'Assert-PSVersion',
    'Invoke-SortVSCodeSettings',
    'ConvertTo-PSSyntax'
)
