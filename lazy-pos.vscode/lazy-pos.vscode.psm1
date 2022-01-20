function Get-VsCodeSettingsPath {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param ()
    Process {
        if ($IsMac) {
            return (Join-Path $HOME Library 'Application Support' Code User settings.json)
        }
        if ($IsWindows) {
            return (Join-Path $env:APPDATA Code User settings.json)
        }
        if ($IsLinux) {
            return (Join-Path $HOME .config Code User settings.json)
        }
    }
}

function Get-VsCodeSettings {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param (
        [Parameter(ParameterSetName = 'AsObject')]
        [bool]$AsObject = $true,
        
        [Parameter(ParameterSetName = 'AsJson')]
        [switch]$AsJsonString,

        [Parameter(ParameterSetName = 'AsPath')]
        [switch]$AsPath,

        [Parameter()]
        [System.IO.FilePath]$Path = (Get-VsCodeSettingsPath)
    )
    Process {
        if ($AsPath) { $Path | Write-Output } 
        $json = $path | Get-Item | Get-Content
        if ($AsJsonString) { $json | Write-Output }
        if ($AsObject) { $json | ConvertFrom-Json }
    }
}

function Add-VsCodeUserSetting {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript({ $_.Count -gt 0 })]
        [System.Collections.IDictionary]$NewSettings
    )
    Begin {
        $userSettingsObject = Get-VsCodeSettingsObject
    }
    Process {
        $userSettingsObject |
            Add-Member -NotePropertyMembers $NewSettings
    }
}
