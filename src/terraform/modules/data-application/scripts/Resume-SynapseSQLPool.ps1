# The parameter names need to be specified in lowercase only. See: "https://github.com/Azure/azure-sdk-for-go/issues/4780
param (
    [String]$subscriptionid,
    [String]$resourcegroupname,
    [String]$workspacename,
    [String]$sqlpoolname
)

# Sign in to Azure subscription
# https://docs.microsoft.com/en-us/powershell/module/az.accounts/connect-azaccount
write-output ("Sign in to Azure using the Managed Identity ...")
Connect-AzAccount -Identity -Subscription $subscriptionid

write-output ("Start Compute in Synapse SQL Pools ...")
# Collect Synapse SQL Pools
# https://docs.microsoft.com/en-us/powershell/module/az.synapse/get-azsynapsesqlpool
try {
    [array]$SqlPools = Get-AzSynapseSqlPool -ResourceGroupName $resourcegroupname -WorkspaceName $workspacename -Name $sqlpoolname |
    Where-Object {
        $PSItem.Tags.Keys -eq "auto_pause" -and
        $PSItem.Tags.Values -eq "enabled" -and
        $PSItem.Status -eq "Paused"
    }
}
catch {
    $ErrorMessage = $PSItem.Exception.message
    write-error ("Could not get list of SqlPools: " + $ErrorMessage)
    break
}

# Start resuming
# https://docs.microsoft.com/en-us/powershell/module/az.synapse/resume-azsynapsesqlpool
foreach ($SqlPool in $SqlPools) {
    try {
        Write-Output "Resuming SQL pool: $( $SqlPool.SqlPoolName )"
        $resultSqlPool = $SqlPool | Resume-AzSynapseSqlPool
    }
    catch {
        $ErrorMessage = $PSItem.Exception.message
        write-error ("Could not resume SQL pool: $($SqlPool.SqlPoolName): " + $ErrorMessage)
    }
}
