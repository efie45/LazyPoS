﻿using namespace Diagnostics.CodeAnalysis

#FEATURE: Firefox Extensions
<#
    JWT Debugger
#>

function Install-WingetProgram() {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param()
    Begin {

        $defaultOptions = '--silent --accept-package-agreements --accept-source-agreements'
        $progList = @(
              ('7zip.7zip', $defaultOptions)
            , ('Appest.TickTick', $defaultOptions)
            , ('Bitwarden.Bitwarden', $defaultOptions)
            , ('Discord.Discord', $defaultOptions)
            , ('Dropbox.Dropbox', $defaultOptions)
            , ('Git.Git', $defaultOptions)
            , ('Github.cli', $defaultOptions)
            , ('GitHub.GitHubDesktop.Beta', $defaultOptions)
            , ('GitHub.GitLFS', $defaultOptions)
            , ('Google.Chrome.Dev', $defaultOptions)
            , ('Greenshot.Greenshot', $defaultOptions)
            , ('JanDeDobbeleer.OhMyPosh', $defaultOptions)
            , ('JetBrains.Rider.EAP', $defaultOptions)
            , ('Klocman.BulkCrapUninstaller', $defaultOptions)
            , ('Microsoft.dotnetRuntime.6-x64', $defaultOptions)
            , ('Microsoft.PowerShell', $defaultOptions)
            , ('Microsoft.WindowsTerminal.Preview', $defaultOptions)
            , ('Microsoft.VisualStudioCode', $defaultOptions)
            , ('Mozilla.Firefox.DeveloperEdition', $defaultOptions)
            , ('Paint.NET', $defaultOptions)
            , ('Postman.Postman.Canary', $defaultOptions)
            , ('Spotify.Spotify', $defaultOptions)
            , ('Valve.Steam', $defaultOptions)
            , ('VideoLAN.VLC', $defaultOptions)
        )
    }
    Process {

        $progList | ForEach-Object {
            & $"winget install $($_[0]) $($_[1])"
        }
    }
}

function Install-Choco {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param ()
    Process {

        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        & ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        & 'choco feature enable -n=allowGlobalConfirmation'
    }
}

function Install-MiscProgram {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param (
        [Parameter(ParameterSetName = 'all')]
        [switch]
        $All,
        [Parameter(ParameterSetName = 'specific')]
        [switch]
        $Wsl
    )
    Process {
        if ($Wsl -or $All) { & 'wsl --install' }
    }
}

function Install-ChocoProgram {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param (
        [Parameter(ParameterSetName = 'all')]
        [switch]
        $All,

        [Parameter(ParameterSetName = 'specific')]
        [switch]
        $NerdFonts
    )
    Process {
        if ($NerdFonts -or $All) { & 'choco install nerd-fonts' }
    }
}

function Install-PowerShellModule {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param ()
    Process {

        Install-Module oh-my-posh -Force
        Install-Module PSScriptAnalyzer -Force
        Install-Module PSReadline -Force
        Set-PSReadLineOption -PredictionSource History
        Install-Module posh-git -Force
        Import-Module posh-git
        Add-GitPoshToProfile

        # Remove version 3 of Pester. Gist script maintained by Pester devs.
        & ((New-Object System.Net.WebClient).DownloadString(
                'https://gist.github.com/nohwnd/5c07fe62c861ee563f69c9ee1f7c9688/raw'))
        Install-Module Pester

    }
}

function Install-VsCodeExtension {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param ()
    Begin {
        $progList = @(
            'GitHub.github-vscode-theme',
            'ms-vscode.powershell',
            'teabyii.ayu',
            'tinkertrain.theme-panda',
            'gruntfuggly.todo-tree'
        )
    }
    Process {

        $progList | ForEach-Object {
            & "code --install-extension $($_)"
        }

        #TODO add to vscode settings: "todo-tree.highlights.useColourScheme": true
    }
}

# function Set-VsCodeExtensionSetting {
#     #TODO The whole thing
#     #TODO "powershell.pester.useLegacyCodeLens": false
# }

function Install-NewWindowsEnvironment {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param ()
    Process {
        Install-WingetPrograms
        Install-Choco
        Install-ChocoPrograms
        Install-MiscPrograms
        Install-PowerShellModules
    }
}

# function Install-Font {
#     <#

#         TODO: Documentation
#         TODO: Unit Tests
#         TODO: Modify with standards

#         Possible with Windows GDI? C++ from PowerShell natively?
#         https://docs.microsoft.com/en-us/windows/win32/api/_gdi/

#         See this stackoverflow conversation
#         https://stackoverflow.com/questions/21986744/how-to-install-a-font-programmatically-c


#     #>
#     [Cmdletbinding()]
#     Param (
#         [Parameter(Mandatory = $true)]
#         [ValidateNotNullOrEmpty()]
#         [System.IO.FileInfo]$Path
#     )

#     $fontFile = Get-Item -Path $Path

#     # Get Font Name from the File's Extended Attributes
#     $oShell = New-Object -com shell.application
#     $Folder = $oShell.namespace($FontFile.DirectoryName)
#     $Item = $Folder.Items().Item($FontFile.Name)
#     $FontName = $Folder.GetDetailsOf($Item, 21)

#     try {
#         $fontName += switch ($fontFile.Extension) {
#             '.ttf' { '(TrueType)' }
#             '.otf' { '(OpenType)' }
#         }
#         Write-Verbose "Copying $($FontFile.Name)....."
#         Copy-Item -Path $fontFile.FullName -Destination "C:\Windows\Fonts\$($FontFile.Name)" -Force -Verbose -ErrorAction Stop

#         #Test if font registry entry exists
#         If ($null -ne (Get-ItemProperty -Name $FontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -ErrorAction SilentlyContinue)) {
#             #Test if the entry matches the font file name
#             if ((Get-ItemPropertyValue -Name $fontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts') -eq $fontFile.Name) {
#                 Write-Verbose "Adding $fontName to the registry....."
#             }
#             else {
#                 $AddKey = $true
#                 Remove-ItemProperty -Name $FontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -Force
#                 Write-Host ('Adding' + [char]32 + $FontName + [char]32 + 'to the registry.....') -NoNewline
#                 New-ItemProperty -Name $FontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null
#                 If ((Get-ItemPropertyValue -Name $FontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts') -eq $FontFile.Name) {
#                     Write-Host ('Success') -ForegroundColor Yellow
#                 }
#                 else {
#                     Write-Host ('Failed') -ForegroundColor Red
#                 }
#                 $AddKey = $false
#             }
#         }
#         else {
#             $AddKey = $true
#             Write-Host ('Adding' + [char]32 + $FontName + [char]32 + 'to the registry.....') -NoNewline
#             New-ItemProperty -Name $FontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null
#             If ((Get-ItemPropertyValue -Name $FontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts') -eq $FontFile.Name) {
#                 Write-Host ('Success') -ForegroundColor Yellow
#             }
#             else {
#                 Write-Host ('Failed') -ForegroundColor Red
#             }
#             $AddKey = $false
#         }

#     }
#     catch {
#         If ($Copy -eq $true) {
#             Write-Host ('Failed') -ForegroundColor Red
#             $Copy = $false
#         }
#         If ($AddKey -eq $true) {
#             Write-Host ('Failed') -ForegroundColor Red
#             $AddKey = $false
#         }
#         Write-Warning $_.exception.message
#     }
#     Write-Host
# }
