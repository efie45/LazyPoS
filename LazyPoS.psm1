function Assert-PSVersion {
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        $MinimumVersion
    )   
    process {
        if ($PSVersionTable.PSVersion -lt $MinimumVersion) {
            throw "PSVersion must be at least $MinimumVersion to use this function"
        }
    }
}

function Invoke-SortVSCodeSettings {
    [Cmdletbinding()]
    param(
        [Parameter()]
        [ValidateScript( { Test-Path -Path $_ })]
        $SettingsPath,

        [Parameter()]
        [switch]$Descending
    )
    process {
        Assert-PSVersion 7
        $SettingsPath ??= $(
            $warning = "No SettingsPath was provided. Using default path for your operating system of "
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

function Convert-JsonToPSSyntax {
    <#
    .DESCRIPTION
    .NOTES
    Probably not the most efficient way of doing this, but I'm usually only using this for small objects when I'm creating tests. 
    You might call it the lazy way...
    #>
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript( { Test-Json $_ })]
        $Json
    )
    process {
        # lazy way to format json with all collection separators at end of lines
        $json = $json | ConvertFrom-Json | ConvertTo-Json -Depth 100
        $Json -replace ",(?=`n)", '' |
        ForEach-Object { $_ -replace '{', '@{' } |
        ForEach-Object { $_ -replace '\[', '@(' } |
        ForEach-Object { $_ -replace ']', ')' } |
        ForEach-Object { $_ -replace ':', ' =' } |
        Write-Output
    }
}

Export-ModuleMember -Function (
    'Assert-PSVersion',
    'Invoke-SortVSCodeSettings',
    'Convert-JsonToPSSyntax'
)
