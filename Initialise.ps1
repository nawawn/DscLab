Configuration DscPrerequisite{
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