Import-Module '../LazyPoS.psm1' -Force

Describe "Lazy PoS Unit Tests"{
    #TODO Context 'Sort-VSCodeSettings' {
    #TODO Context 'Assert-PSVersion' {
    Context "Convert-JsonToPSSyntax" {
        It "Creates the correct object from example JSON" {
            $json = Get-Content "./example.json" -Raw
            $json | ConvertTo-PSSyntax | Write-Host
        }
    }
}
