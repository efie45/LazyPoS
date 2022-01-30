function Get-VsCodeSettingsPath {
    #TODO: Documentation
    #TODO: Unit Tests
    [OutputType([string])]
    [Cmdletbinding()]
    Param ()
    Process {
        if ($IsMac) {
            return "$HOME/Library/Application Support/Code User/settings.json"
        }
        if ($IsWindows) {
            return "$ENV:APPDATA/Code/User/settings.json"
        }
        if ($IsLinux) {
            return "$HOME/.config/Code/User/settings.json"
        }
    }
}

function Get-VsCodeSetting {
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
