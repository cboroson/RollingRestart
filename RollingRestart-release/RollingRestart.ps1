Trace-VstsEnteringInvocation $MyInvocation

$ResourceGroup = Get-VstsInput -Name "ResourceGroupName"
$AppServiceName = Get-VstsInput -Name "AppServiceName"
$SecondsBetweenRestarts = Get-VstsInput -Name "SecondsBetweenRestarts"

################# Initialize Azure. #################
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Initialize-Azure

$VerbosePreference = "Continue"

# This gives you a list of instances for your App Service
$InstancesSplat = @{
    ResourceGroupName = $ResourceGroup
    ResourceType = "Microsoft.Web/sites/instances"
    ResourceName = $AppServiceName
    ApiVersion = "2018-11-01"
}
$ApplicationInstances = Get-AzureRMResource @InstancesSplat

$InstanceCounter = 0
$FailedRestarts = $false
foreach ($Instance in $ApplicationInstances) {
    $InstanceCounter++
    Write-Host "Now on instance $InstanceCounter/$($ApplicationInstances.Count)"

    # This gives you list of processes running on a particular instance, filtered to only IIS processes
    $ProcessListSplat = @{
        ResourceGroupName = $ResourceGroup
        ResourceType = "Microsoft.Web/sites/instances/processes"
        ResourceName = "$AppServiceName/$($Instance.Name)"
        ApiVersion = "2018-11-01"
    }
    $ProcessList = Get-AzureRMResource @ProcessListSplat | Where-Object { $_.Properties.Name -eq "w3wp" }

    foreach ($Process in $ProcessList) {
        $ProcessWithPropertiesSplat = @{
            ResourceGroupName = $ResourceGroup
            ResourceType = "Microsoft.Web/sites/instances/processes"
            ResourceName = "$AppServiceName/$($Instance.Name)/$($Process.Properties.id)"
            ApiVersion = "2018-11-01"
        }                       
        $ProcessWithProperties = Get-AzureRMResource @ProcessWithPropertiesSplat

        # 'is_scm_site' is a property which is set on the Kudu worker process, which you don't want to restart
        if ($ProcessWithProperties.Properties.is_scm_site -ne $true) {
            Write-Host "Instance ID $($Instance.Name) has computer name $($ProcessWithProperties.Properties.environment_variables.COMPUTERNAME)"

            Write-Host "Stopping process with PID $($ProcessWithProperties.Properties.Id)"

            # Remove-AzResource stops the IIS process, which will then automatically restart
            $Result = Remove-AzureRMResource -ResourceId $ProcessWithProperties.ResourceId -ApiVersion 2018-11-01 -Force

            if ($Result -eq $true) { 
                Write-Host "Process $($ProcessWithProperties.Properties.Id) restarted with a new PID."
            }
            else {
                Write-Error "Problem stopping process $($ProcessWithProperties.Properties.Id) on instance $($Instance.Name)."
                $FailedRestarts = $true
            }

            if ($InstanceCounter -lt $ApplicationInstances.Count) {
                Write-Host "Sleeping for $SecondsBetweenRestarts seconds before next reboot..."
                Start-Sleep -s $SecondsBetweenRestarts
            }
        }
    }
}

if ($FailedRestarts) {
    throw "At least one restart failed. Please review output for details."
}

Trace-VstsLeavingInvocation $MyInvocation
