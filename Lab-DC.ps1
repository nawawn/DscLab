Configuration DCconfig {
    Param(
        [Parameter(Mandatory)]
        [PSCredential]$SafeModeAdminCred,

        [Parameter(Mandatory)]
        [PSCredential]$DomainAdminCred,

        [Parameter(Mandatory)]
        [PSCredential]$ADUserCred
    )

    Import-DscResource -ModuleName xActiveDirectory,PSDesiredStateConfiguration

    Node $AllNodes.Where{$_.Role -eq 'Primary DC'}.Nodename {        
        WindowsFeature ADDSInstall{
            Name = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        xADDomain FirstDS {
            DomainAdministratorCredential = $DomainAdminCred
            DomainName = $Node.DomainName
            SafemodeAdministratorPassword = $SafeModeAdminCred            
            DependsOn = '[WindowsFeature]ADDSInstall'
            
        }
        
        xADOrganizationalUnit User {
            Name = "DomainUsers"
            Path = "DC=dsclab,DC=com"           
            Credential = $DomainAdminCred
            DependsOn = '[xADDomain]FirstDS'
            Description = "Parent Users OU"
            Ensure = 'Present'
            ProtectedFromAccidentalDeletion = $true
        }

        xADOrganizationalUnit Computer {
            Name = "DomainComputers"
            Path = "DC=dsclab,DC=com"           
            Credential = $DomainAdminCred
            DependsOn = '[xADDomain]FirstDS'
            Description = "Parent Computers OU"
            Ensure = 'Present'
            ProtectedFromAccidentalDeletion = $true
                    
        }        

        xADUser ADUser{
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $DomainAdminCred
            UserName = 'Lab.User'
            Password = $ADUserCred            
            Description = 'Deployed by DSC'                      
            Ensure = 'Present'
            DependsOn = '[xADDomain]FirstDS'        
        }
    }
}

$ConfigData = @{
    AllNodes = @(
        @{
            Nodename = '*'
            DomainName = 'dsclab.com'
            RetryCount = 20
            RetryIntervalSec = 30
            PSDscAllowPlainTextPassword = $true        
        },        
        @{
            Nodename = '192.168.2.10'
            Role = 'Primary DC'        
        }    
    )
}

DCconfig -ConfigurationData $ConfigData