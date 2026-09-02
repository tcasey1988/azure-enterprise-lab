BeforeAll {
    $ProjectRoot = Resolve-Path (
        Join-Path $PSScriptRoot ".."
    )

    $ConfigurationPath = Join-Path `
        $ProjectRoot `
        "config/lab.json"

    $Configuration = Get-Content `
        -Path $ConfigurationPath `
        -Raw |
        ConvertFrom-Json
}

Describe "Azure Enterprise Lab configuration" {
    It "uses the expected project name" {
        $Configuration.projectName |
            Should -Be "Azure Enterprise Lab"
    }

    It "defines an Azure region" {
        $Configuration.azure.region |
            Should -Not -BeNullOrEmpty
    }

    It "defines a resource group" {
        $Configuration.azure.resourceGroupName |
            Should -Not -BeNullOrEmpty
    }

    It "uses private RFC1918 network space" {
        $Configuration.network.addressSpace |
            Should -Match "^10\."
    }

    It "defines the domain controller" {
        $Configuration.activeDirectory.domainControllerName |
            Should -Be "AZLAB-DC01"
    }

    It "defines the management server" {
        $Configuration.activeDirectory.managementServerName |
            Should -Be "AZLAB-MGMT01"
    }

    It "uses the September 25 teardown deadline" {
        $Configuration.schedule.mandatoryTeardownDate |
            Should -Be "2026-09-25"
    }
}