using namespace System.Collections.Generic
using namespace System.Text

BeforeAll {
    Import-Module (Resolve-Path "$PSScriptRoot/../lazy-pos.misc/lazy-pos.misc.psm1") -Force
}

Describe 'Lazy PoS Unit Tests' {

    #TODO Context 'Sort-VSCodeSettings'

    Context 'Assert-PSVersion' -Skip {
        $incorrectVersions = '8', 8, '8.0', '8.1.2', [version]'8.0'
        It 'Throws error for incorrect versions' -ForEach $incorrectVersions {
            { Assert-PSVersion -MinimumVersion $_ -CurrentVersion $([Version]'7.1.0') } | Should -Throw
        }

        $correctVersions = 7, '7.1.0', '7.1', '7.1', '7'
        It "Doesn't throw error for correct versions" -ForEach $correctVersions {
            { Assert-PSVersion -MinimumVersion $_ -CurrentVersion $([Version]'7.1.0') } | Should -Not -Throw
        }
    }
    Context 'Get-RandomAlpha' -Tag unit, misc {
        It 'Should get a random character' -ForEach (1..5) {
            $char = Get-RandomAlpha -Uppercase
            $char | Should -BeOfType ([char])
            $char | Should -MatchExactly '[A-Z]'
        }

        It 'Should get a random character' -ForEach (1..5) {
            $char = Get-RandomAlpha -Lowercase
            $char | Should -BeOfType ([char])
            $char | Should -MatchExactly '[a-z]'
        }
    }
    Context 'ConvertTo-Version' {
        It 'Should throw when non digits are provided' {
            { '1.t1' | ConvertTo-Version } | Should -Throw -ExceptionType ([ArgumentException])
        }

        It 'Should throw when any subvalues are longer than 10 digits' {
            # Arrange
            $tooManyDigitsInMajor = { '12345678901.2.3' | ConvertTo-Version }
            # Assert
            $tooManyDigitsInMajor | Should -Throw -ExceptionType ([ArgumentException])
        }

        It 'Should write warning no minor version is provided' {
            # Arrange
            $warnings = [List[string]]::new()
            Mock Write-Warning -Verifiable -ModuleName 'lazy-pos.misc' {
                $warnings.Add($Message)
            }
            # Act
            '1' | ConvertTo-Version
            # Assert
            Should -InvokeVerifiable
            $warnings.Count | Should -BeExactly 1
        }

        It 'Should write warning when version will be truncated to 4 values' {
            # Arrange
            $warnings = [List[string]]::new()
            Mock Write-Warning -Verifiable -ModuleName 'lazy-pos.misc' {
                $warnings.Add($Message)
            }
            # Act
            '1.2.3.4.5' | ConvertTo-Version
            # Assert
            Should -InvokeVerifiable
            $warnings.Count | Should -BeExactly 1
        }

        It 'Should fail for decimal inputs over to 1.2147483647' {
            { 1.2147483648 | ConvertTo-Version } | Should -Throw -ExceptionType ([ArgumentException])
        }

        $validInts = [List[int]]::new()
        0..25 | ForEach-Object { $validInts.Add((Get-Random -Minimum 0 -Maximum ([int32]::MaxValue))) }
        It 'Should work for valid int inputs' -ForEach $validInts {
            # Arrange
            Mock Write-Warning {} -ModuleName 'lazy-pos.misc'
            # Act
            $result = $_ | ConvertTo-Version
            # Assert
            $result | Should -BeOfType ([Version])
        }

        $validDecimals = [List[decimal]]::new()
        0..25 | ForEach-Object {
            $randomDec = Get-Random -Minimum 1.0 -Maximum 1.2147483647
            $validDecimals.Add($randomDec)
        }
        It 'Should work for valid decimal inputs' -ForEach $validDecimals {
            # Arrange
            Mock Write-Warning {} -ModuleName 'lazy-pos.misc'
            # Act
            $result = $_ | ConvertTo-Version
            # Assert
            $result | Should -BeOfType ([Version])
        }

        $validStrings = [List[string]]::new()
        0..25 | ForEach-Object {
            $strBuilder = [StringBuilder]::new()
            # Maximum is non-inclusive
            1..(Get-Random -Minimum 1 -Maximum 5) | ForEach-Object {
                $strBuilder.Append((Get-Random -Minimum 0 -Maximum ([int32]::MaxValue)))
                $strBuilder.Append('.')
            }
            # Remove last '.'
            $strBuilder.Remove($strBuilder.Length - 1, 1)
            $validStrings.Add($strBuilder.ToString())
        }
        It 'Should work for valid string inputs' -ForEach $validStrings {
            # Arrange
            Mock Write-Warning {} -ModuleName 'lazy-pos.misc'
            # Act
            $result = $_ | ConvertTo-Version
            # Assert
            $result | Should -BeOfType ([Version])
        }
    }

    Context 'Convert-JsonToPSSyntax' -Skip {
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
