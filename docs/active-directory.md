# Active Directory Design

## Domain

- DNS domain: `corp.aelab.test`
- NetBIOS domain: `AEL`
- Domain controller: `AEL-DC01`
- Management host: `AEL-MGMT01`

## Organizational units

- `AEL/Users/Finance`
- `AEL/Users/IT`
- `AEL/Users/Operations`
- `AEL/Groups`
- `AEL/Computers`
- `AEL/Servers`

## Security groups

- `GG-All-Employees`
- `GG-Finance-Users`
- `GG-IT-Users`
- `GG-Operations-Users`

Six fictional employee accounts are distributed across Finance, IT, and Operations. Departmental group membership provides the foundation for later role-based access assignments.

`AEL-MGMT01` resides in the managed Computers OU. `AEL-DC01` remains in the built-in Domain Controllers OU.


## Management Workstation Group Policy

The `AEL - Management Security Baseline` GPO is linked to the
`AEL/Computers` OU and currently applies to `AEL-MGMT01`.

Configured settings:

- Machine inactivity timeout: 900 seconds
- SMBv1 server protocol: disabled
- Windows PowerShell script-block logging: enabled

The GPO was created, linked, configured, and validated with PowerShell.
The default domain and domain controller policies were not modified.