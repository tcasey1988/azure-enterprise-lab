<#
.SYNOPSIS
    Validates the Azure Enterprise Lab development environment.

.DESCRIPTION
    Confirms that required local tools are available, validates the lab
    configuration, analyzes PowerShell scripts, and runs Pester tests.

.EXAMPLE
    ./scripts/Invoke-ProjectValidation.ps1
#>

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    "PSAvoidUsingWriteHost",
    "",
    Justification = "This interactive validation script uses color-coded host output for local developer feedback."
)]
param ()

$ErrorActionPreference = "Stop"
$ValidationFailed = $false

$ProjectRoot = Split-Path -Path $PSScriptRoot -Parent
$ConfigurationPath = Join-Path $ProjectRoot "config/lab.json"
$TestsPath = Join-Path $ProjectRoot "tests"

Write-Host ""
Write-Host "Azure Enterprise Lab Validation" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

if ($PSVersionTable.PSVersion.Major -ge 7) {
    Write-Host "PASS: PowerShell $($PSVersionTable.PSVersion)" `
        -ForegroundColor Green
}
else {
    Write-Host "FAIL: PowerShell 7 or later is required." `
        -ForegroundColor Red

    $ValidationFailed = $true
}

foreach ($Tool in @("git", "terraform", "az")) {
    if (Get-Command -Name $Tool -ErrorAction SilentlyContinue) {
        Write-Host "PASS: $Tool is available." `
            -ForegroundColor Green
    }
    else {
        Write-Host "FAIL: $Tool was not found." `
            -ForegroundColor Red

        $ValidationFailed = $true
    }
}

foreach ($ModuleName in @("Pester", "PSScriptAnalyzer")) {
    if (Get-Module -ListAvailable -Name $ModuleName) {
        Write-Host "PASS: $ModuleName is installed." `
            -ForegroundColor Green
    }
    else {
        Write-Host "FAIL: $ModuleName is not installed." `
            -ForegroundColor Red

        $ValidationFailed = $true
    }
}

try {
    $Configuration = Get-Content `
        -Path $ConfigurationPath `
        -Raw |
        ConvertFrom-Json

    $RequiredValues = @{
        ProjectName      = $Configuration.projectName
        TeardownDate     = $Configuration.schedule.mandatoryTeardownDate
        Region           = $Configuration.azure.region
        ResourceGroup    = $Configuration.azure.resourceGroupName
        AddressSpace     = $Configuration.network.addressSpace
        DomainName       = $Configuration.activeDirectory.domainName
        DomainController = $Configuration.activeDirectory.domainControllerName
        ManagementServer = $Configuration.activeDirectory.managementServerName
    }

    foreach ($Item in $RequiredValues.GetEnumerator()) {
        if ([string]::IsNullOrWhiteSpace([string]$Item.Value)) {
            Write-Host "FAIL: '$($Item.Key)' is missing." `
                -ForegroundColor Red

            $ValidationFailed = $true
        }
    }

    Write-Host "PASS: Lab configuration loaded." `
        -ForegroundColor Green
}
catch {
    Write-Host "FAIL: Unable to load lab configuration." `
        -ForegroundColor Red

    Write-Host $_.Exception.Message -ForegroundColor Red
    $ValidationFailed = $true
}

Import-Module PSScriptAnalyzer -ErrorAction Stop

$AnalyzerResults = Invoke-ScriptAnalyzer `
    -Path $PSScriptRoot `
    -Recurse `
    -Severity Warning, Error

if ($AnalyzerResults) {
    $AnalyzerResults |
        Format-Table `
            RuleName,
            Severity,
            ScriptName,
            Line,
            Message `
            -Wrap

    Write-Host "FAIL: PSScriptAnalyzer found problems." `
        -ForegroundColor Red

    $ValidationFailed = $true
}
else {
    Write-Host "PASS: PSScriptAnalyzer found no problems." `
        -ForegroundColor Green
}

Import-Module Pester -MinimumVersion 5.5.0 -ErrorAction Stop

$PesterResults = Invoke-Pester `
    -Path $TestsPath `
    -PassThru

if ($PesterResults.FailedCount -gt 0) {
    Write-Host "FAIL: $($PesterResults.FailedCount) test(s) failed." `
        -ForegroundColor Red

    $ValidationFailed = $true
}
else {
    Write-Host "PASS: All $($PesterResults.PassedCount) tests passed." `
        -ForegroundColor Green
}

if ($ValidationFailed) {
    throw "Azure Enterprise Lab validation failed."
}

Write-Host ""
Write-Host "Project validation completed successfully." `
    -ForegroundColor Green