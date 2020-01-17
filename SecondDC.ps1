Configuration JustAnotherDC{
    param(
        [Parameter(Mandatory,position=0)][ValidateNotNullOrEmpty()]
        [PSCredential]$SafeModeCred,
        [Parameter(Mandatory,position=1)][ValidateNotNullOrEmpty()]
        [PSCredential]$DomainAdminCred
    )
    Import-DscResource -ModuleName PSDesiredstateConfiguration,ActiveDirectoryDsc

    Node localhost{
        WindowsFeature InstallADDS{
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        } 
        WindowsFeature InstallDNS{
            Name   = 'DNS'
            Ensure = 'Present'
        } 
        WindowsFeature GPMC{
            Name   = 'GPMC'
            Ensure = 'Present'
        } 
        WindowsFeature Rsat{
            Name   = 'RSAT'
            Ensure = 'Present'
        } 
        WindowsFeature RsatRoleTools{
            Name   = 'RSAT-Role-Tools'
            Ensure = 'Present'
        } 
        WindowsFeature RsatADTools{
            Name   = 'RSAT-AD-Tools'
            Ensure = 'Present'
        } 
        WindowsFeature RsatADPS{
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
            DependsOn = '[WindowsFeature]InstallADDS'
        } 
        WindowsFeature RsatADDS{
            Name   = 'RSAT-ADDS'
            Ensure = 'Present'
        }
        WindowsFeature RsatADAC{
            Name   = 'RSAT-AD-AdminCenter'
            Ensure = 'Present'
        }
        WindowsFeature RsatADDSTools{
            Name   = 'RSAT-ADDS-Tools'
            Ensure = 'Present'
        }
        WindowsFeature RsatDNSSrv{
            Name   = 'RSAT-DNS-Server'
            Ensure = 'Present'
        }
        WaitforADDomain WaitForADForest{
            DomainName = 'dsclab.local'
            Credential = $DomainAdminCred
            DependsOn  = '[WindowsFeature]RsatADPS'
        }
        ADDomainController AdditionalDC{
            DomainName      = 'dsclab.local'
            Credential      = $DomainAdminCred
            SafeModeAdministratorPassword = $SafeModeCred
            Sitename        = 'London'
            IsGlobalCatalog = $true
            DependsOn       = '[WaitForADDomain]WaitForADForest'
        }          
    }
}

$Config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowDomainUser = $true
            PSDscAllowPlainTextPassword = $true        
        }
    )
}

$SafeMode   = (Get-Credential)
$DomainCred = (Get-Credential)
JustAnotherDC -OutputPath C:\PSscripts -SafeModeCred $SafeMode -DomainAdminCred $DomainCred -ConfigurationData $Config

Start-DscConfiguration -Path C:\PSscripts -Wait -Force -Verbose
