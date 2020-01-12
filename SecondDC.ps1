Configuration SecondaryDC{
    Param(
        [Parameter(Mandatory)]
        [PSCredential]$SafeModeAdminCred,

        [Parameter(Mandatory)]
        [PSCredential]$DomainAdminCred
    )
    #$ModuleList = @('ActiveDirectoryDsc','NetworkingDsc','ComputerManagementDsc','DFSDsc')
    Import-DscResource -ModuleName ActiveDirectoryDsc,PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc,DFSDsc,NetworkingDsc

    Node localhost{
        WindowsFeature InstallDns{
            Name   = 'DNS'
            Ensure = 'Present'
        }
        WindowsFeature InstallADDS{
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
            DependsOn = '[WindowsFeature]InstallDns'
        }
        WindowsFeature InstallRsatADPS{
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
            DependsOn = '[WindowsFeature]InstallADDS'
        }
        WaitForADDomain WaitForForest{
            DomainName = 'dsclab.com'
            Credential = $DomainAdminCred
            DependsOn  = '[WindowsFeature]InstallRsatADPS'
        }
        
        ADDomainController SecondDS{
            DomainName      = 'dsclab.com'
            Credential      = $DomainAdminCred
            SafeModeAdministratorPassword = $SafeModeAdminCred
            SiteName        = 'London'
            IsGlobalCatalog = $true
            DependsOn       = '[WaitForADDomain]WaitForForest'
        }
    }
}