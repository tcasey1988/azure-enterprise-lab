# Azure Enterprise Lab

Azure Enterprise Lab is a focused hybrid infrastructure and identity project
using Microsoft Azure, Windows Server Active Directory, Microsoft Entra ID,
Terraform, and practical PowerShell automation.

## Current Deployment

The Azure network foundation is deployed through Terraform.

- Resource group: `rg-ael-dev`
- Virtual network: `vnet-ael-dev`
- VNet address space: `10.20.0.0/16`
- Management subnet: `10.20.1.0/24`
- Server subnet: `10.20.2.0/24`
- Separate NSGs are associated with each subnet