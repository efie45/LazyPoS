function Install-WingetPrograms() {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param()
    Begin {

        $defaultOptions = '--silent --accept-package-agreements --accept-source-agreements'
        $progList = @(  
              ('Microsoft.VisualStudioCode', $defaultOptions)
            , ('Google.Chrome.Dev', $defaultOptions)
            , ('Mozilla.Firefox.DeveloperEdition', $defaultOptions)
            , ('Microsoft.WindowsTerminal.Preview', $defaultOptions)
            , ('Microsoft.PowerShell', $defaultOptions)
            , ('JanDeDobbeleer.OhMyPosh', $defaultOptions)
            , ('Git.Git', $defaultOptions)
            , ('GitHub.GitLFS', $defaultOptions)
            , ('GitHub.GitHubDesktop.Beta', $defaultOptions)
            , ('Github.cli', $defaultOptions)
            , ('Postman.Postman.Canary', $defaultOptions)
            , ('JetBrains.Rider.EAP', $defaultOptions)
            , ('Dropbox.Dropbox', $defaultOptions)
            , ('Bitwarden.Bitwarden', $defaultOptions)
            , ('Valve.Steam', $defaultOptions)
            , ('Spotify.Spotify', $defaultOptions)
            , ('Greenshot.Greenshot', $defaultOptions)
            , ('Microsoft.dotnetRuntime.6-x64', $defaultOptions)
            , ('7zip.7zip', $defaultOptions)
            , ('VideoLAN.VLC', $defaultOptions)
            , ('Paint.NET', $defaultOptions)
            , ('Discord.Discord', $defaultOptions)
            , ('Appest.TickTick', $defaultOptions)
            , ('Klocman.BulkCrapUninstaller', $defaultOptions)
        )
    }
    Process {

        $progList | ForEach-Object -Parallel {
            Invoke-Expression $"winget install $($_[0]) $($_[1])"
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
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Invoke-Expression 'choco feature enable -n=allowGlobalConfirmation'
    }
}

function Install-MiscPrograms {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param ()
    Process {

        Invoke-Expression 'wsl --install'
    }
}

function Install-ChocoPrograms {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param ()
    Process {

        Invoke-Expression 'choco install nerd-fonts'
    }
}

function Install-PowerShellModules {
    #TODO: Documentation
    #TODO: Unit Tests
    [Cmdletbinding()]
    Param ()
    Process {
        
        Install-Module oh-my-posh -Force
        Install-Module PSScriptAnalyzer -Force
        Install-Module PSReadline -Force
        Set-PSReadLineOption -PredictionSource History

        #Remove version 3 of Pester. Gist script maintained by Pester devs.
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://gist.github.com/nohwnd/5c07fe62c861ee563f69c9ee1f7c9688/raw'))
        Install-Module Pester

    }
}

function Install-VSCodeExtensions {
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
            Invoke-Expression "code --install-extension $($_)"
        }

        #TODO add to vscode settings: "todo-tree.highlights.useColourScheme": true
    }
}

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

