function Sort-VSCodeSettings {
    [Cmdletbinding()]
    param(
        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $SettingsPath,

        [Parameter()]
        [switch]$Descending
    )
    Assert-PSVersion 7
    $SettingsPath ??= $(
        $warning = "No SettingsPath was provided. Using default path for your operating system of "
        if ($IsMacOS) { "$HOME/Library/Application Support/Code/User/settings.json" }
        if ($IsWindows) { "$env:APPDATA\Code\User\settings.json" }
        if ($IsLinux) { "$HOME/.config/Code/User/settings.json" }
    )
    if ($warning) { $warning += $SettingsPath | Write-Warning }
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

function Assert-PSVersion {
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        $MinimumVersion
    )   
    if ($PSVersionTable.PSVersion -lt $MinimumVersion) {
        throw "PSVersion must be at least $MinimumVersion to use this function"
    }
}