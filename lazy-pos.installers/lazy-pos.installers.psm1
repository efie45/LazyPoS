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

        $progList | ForEach-Object {
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
        Install-Module posh-git -Force
        Import-Module posh-git
        Add-GitPoshToProfile

        # Remove version 3 of Pester. Gist script maintained by Pester devs.
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://gist.github.com/nohwnd/5c07fe62c861ee563f69c9ee1f7c9688/raw'))
        Install-Module Pester

    }
}

function Install-VsCodeExtensions {
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

function Set-VsCodeExtensionSettings {
    #TODO The whole thing
    #TODO "powershell.pester.useLegacyCodeLens": false
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

function Install-Font {  
    <#
        
        TODO: Documentation
        TODO: Unit Tests
        TODO: Modify with standards

        Possible with Windows GDI? C++ from PowerShell natively?
        https://docs.microsoft.com/en-us/windows/win32/api/_gdi/

        See this stackoverflow conversation
        https://stackoverflow.com/questions/21986744/how-to-install-a-font-programmatically-c


    #>
    [Cmdletbinding()]
    Param ( 
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]$Path
    )

    $fontFile = Get-Item -Path $Path
      
    # Get Font Name from the File's Extended Attributes  
    $oShell = New-Object -com shell.application  
    $Folder = $oShell.namespace($FontFile.DirectoryName)  
    $Item = $Folder.Items().Item($FontFile.Name)  
    $FontName = $Folder.GetDetailsOf($Item, 21)  

    try {  
        $fontName += switch ($fontFile.Extension) {  
            '.ttf' { '(TrueType)' } 
            '.otf' { '(OpenType)' }  
        }  
        Write-Verbose "Copying $($FontFile.Name)....."  
        Copy-Item -Path $fontFile.FullName -Destination "C:\Windows\Fonts\$($FontFile.Name)" -Force -Verbose -ErrorAction Stop

        #Test if font registry entry exists  
        If ($null -ne (Get-ItemProperty -Name $FontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -ErrorAction SilentlyContinue)) {  
            #Test if the entry matches the font file name  
            if ((Get-ItemPropertyValue -Name $fontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts') -eq $fontFile.Name) {  
                Write-Verbose "Adding $fontName to the registry....." 
            }
            else {  
                $AddKey = $true  
                Remove-ItemProperty -Name $FontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -Force  
                Write-Host ('Adding' + [char]32 + $FontName + [char]32 + 'to the registry.....') -NoNewline  
                New-ItemProperty -Name $FontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null  
                If ((Get-ItemPropertyValue -Name $FontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts') -eq $FontFile.Name) {  
                    Write-Host ('Success') -ForegroundColor Yellow  
                }
                else {  
                    Write-Host ('Failed') -ForegroundColor Red  
                }  
                $AddKey = $false  
            }  
        }
        else {  
            $AddKey = $true  
            Write-Host ('Adding' + [char]32 + $FontName + [char]32 + 'to the registry.....') -NoNewline  
            New-ItemProperty -Name $FontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null  
            If ((Get-ItemPropertyValue -Name $FontName -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts') -eq $FontFile.Name) {  
                Write-Host ('Success') -ForegroundColor Yellow  
            }
            else {  
                Write-Host ('Failed') -ForegroundColor Red  
            }  
            $AddKey = $false  
        }  
           
    }
    catch {  
        If ($Copy -eq $true) {  
            Write-Host ('Failed') -ForegroundColor Red  
            $Copy = $false  
        }  
        If ($AddKey -eq $true) {  
            Write-Host ('Failed') -ForegroundColor Red  
            $AddKey = $false  
        }  
        Write-Warning $_.exception.message  
    }  
    Write-Host  
}  
