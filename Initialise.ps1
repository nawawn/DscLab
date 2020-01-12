Configuration DscInit{
    Param(
        [Parameter(Mandatory)]        
        [PSCredential]$PSDscRunAsCred = (Get-Credential -Message 'Enter DscRunAs User Details')
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node localhost{
        File CreateTempFolder{            
            DestinationPath = 'C:\temp'
            Ensure          = 'Present'
            Type            = 'Directory'            
        }
        #Update this with Foreach loop later
        File CopyNetworkingDsc{
            SourcePath      = '\\FileServer\Share\PSModules\NetworkingDsc'
            DestinationPath = 'C:\Program Files\WindowsPowerShell\Modules'                       
            MatchSource     = $true            
            Recurse         = $true
            Ensure          = 'Present' 
            PsDscRunAsCredential = $PSDscRunAsCred
        }
        File CopyActiveDirectoryDsc{            
            SourcePath      = '\\FileServer\Share\PSModules\ActiveDirectoryDsc'
            DestinationPath = 'C:\Program Files\WindowsPowerShell\Modules'                       
            MatchSource     = $true            
            Recurse         = $true
            Ensure          = 'Present' 
            PsDscRunAsCredential = $PSDscRunAsCred
        }
        File CopyDFSDsc{            
            SourcePath      = '\\FileServer\Share\PSModules\DFSDsc'
            DestinationPath = 'C:\Program Files\WindowsPowerShell\Modules'                       
            MatchSource     = $true            
            Recurse         = $true
            Ensure          = 'Present' 
            PsDscRunAsCredential = $PSDscRunAsCred
        }
        File CopyComputerManagementDsc{            
            SourcePath      = '\\FileServer\Share\PSModules\ComputerManagementDsc'
            DestinationPath = 'C:\Program Files\WindowsPowerShell\Modules'                       
            MatchSource     = $true            
            Recurse         = $true
            Ensure          = 'Present' 
            PsDscRunAsCredential = $PSDscRunAsCred
        } 
    }
}

[DSCLocalConfigurationManager()]
Configuration LCMConfig{
    Node localhost{
        Settings{
            ActionAfterReboot  = 'ContinueConfiguration'
            ConfigurationMode  = 'ApplyAndMonitor'
            RefreshMode        = 'Push'
            RebootNodeIfNeeded = $true
        }
    }
}


LCMConfig C:\Temp
Set-DscLocalConfigurationManager -Path C:\Temp

DscInit C:\Temp
Start-DscConfiguration -Path C:\Temp -Wait -Force