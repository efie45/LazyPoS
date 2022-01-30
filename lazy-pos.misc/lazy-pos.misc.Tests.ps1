BeforeAll {
    Import-Module (Resolve-Path "$PSScriptRoot/../lazy-pos.misc/lazy-pos.misc.psm1")
}

Describe 'Lazy PoS Unit Tests' {

    #TODO Context 'Sort-VSCodeSettings'

    Context 'Assert-PSVersion' {
        $incorrectVersions = '8', 8, '8.0', '8.1.2', [version]'8.0'
        It 'Throws error for incorrect versions' -Foreach $incorrectVersions {
            { Assert-PSVersion -MinimumVersion $_ -CurrentVersion $([Version]'7.1.0') } | Should -Throw
        }
        $correctVersions = 7, '7.1.0', '7.1', '7.1', '7'
        It "Doesn't throw error for correct versions" -Foreach $correctVersions {
            { Assert-PSVersion -MinimumVersion $_ -CurrentVersion $([Version]'7.1.0') } | Should -Not -Throw
        }
    }

    Context 'Convert-JsonToPSSyntax' {
        <#
            BUG
            Needs to pipe to should operator
            Isn't working as expected
        # #>
        # It 'Creates the correct object from example JSON' {
        #     $json = Get-Content './example.json' -Raw
        #     $json | ConvertTo-PSSyntax | Write-Host
        # }
    }
}
