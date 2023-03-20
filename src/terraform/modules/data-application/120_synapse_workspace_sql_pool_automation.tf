# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook
resource "azurerm_automation_runbook" "resume_synapse_sql_pool" {
  name                    = "ResumeSynapseSQLPool"
  location                = var.location
  resource_group_name     = var.mgmt_resource_group_name
  automation_account_name = var.automation_account_name
  content                 = data.local_file.resume_synapse_sql_pool.content
  description             = "Resume Azure Synapse SQL Pool"
  log_progress            = "true"
  log_verbose             = "false"
  runbook_type            = "PowerShell"
}

resource "azurerm_automation_runbook" "suspend_synapse_sql_pool" {
  name                    = "SuspendSynapseSQLPool"
  location                = var.location
  resource_group_name     = var.mgmt_resource_group_name
  automation_account_name = var.automation_account_name
  content                 = data.local_file.suspend_synapse_sql_pool.content
  description             = "Suspend Azure Synapse SQL Pool"
  log_progress            = "true"
  log_verbose             = "false"
  runbook_type            = "PowerShell"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule
resource "azurerm_automation_schedule" "resume_synapse_sql_pool" {
  name                    = "ResumeSynapseSQLPool"
  resource_group_name     = var.mgmt_resource_group_name
  automation_account_name = var.automation_account_name
  description             = "Resume Synapse SQLPool\nTimezone always UTC"
  expiry_time             = "9999-12-31T23:59:00Z"
  frequency               = "Day"
  interval                = 1
  start_time              = "${formatdate("YYYY-MM-DD", timeadd(timestamp(), "24h"))}T06:00:00+00:00"
  timezone                = "Etc/UTC"

  lifecycle {
    ignore_changes = [
      start_time
    ]
  }
}

resource "azurerm_automation_schedule" "suspend_synapse_sql_pool" {
  name                    = "SuspendSynapseSQLPool"
  resource_group_name     = var.mgmt_resource_group_name
  automation_account_name = var.automation_account_name
  description             = "Suspend Synapse SQL Pool\nTimezone always UTC"
  expiry_time             = "9999-12-31T23:59:00Z"
  frequency               = "Day"
  interval                = 1
  # start_time              = "${formatdate("YYYY-MM-DD", timestamp())}T17:00:00+00:00"
  start_time = "${formatdate("YYYY-MM-DD", timeadd(timestamp(), "24h"))}T17:00:00+00:00"
  timezone   = "Etc/UTC"

  lifecycle {
    ignore_changes = [
      start_time
    ]
  }
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule
resource "azurerm_automation_job_schedule" "resume_synapse_sql_pool" {
  for_each = {
    for o in azurerm_synapse_sql_pool.this : lower(replace(o.name, " ", "_")) => o if try(o.tags.auto_pause == "enabled", false)
  }

  resource_group_name     = var.mgmt_resource_group_name
  automation_account_name = var.automation_account_name
  runbook_name            = azurerm_automation_runbook.resume_synapse_sql_pool.name
  schedule_name           = azurerm_automation_schedule.resume_synapse_sql_pool.name

  # The parameter names need to be specified in lowercase only. See: "https://github.com/Azure/azure-sdk-for-go/issues/4780
  parameters = {
    subscriptionid    = "${data.azurerm_client_config.client_config.subscription_id}"
    resourcegroupname = "${azurerm_resource_group.this.name}"
    workspacename     = "${azurerm_synapse_workspace.this.name}"
    sqlpoolname       = "${each.value.name}"
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule
resource "azurerm_automation_job_schedule" "suspend_synapse_sql_pool" {
  for_each = {
    for o in azurerm_synapse_sql_pool.this : lower(replace(o.name, " ", "_")) => o if try(o.tags.auto_pause == "enabled", false)
  }

  resource_group_name     = var.mgmt_resource_group_name
  automation_account_name = var.automation_account_name
  runbook_name            = azurerm_automation_runbook.suspend_synapse_sql_pool.name
  schedule_name           = azurerm_automation_schedule.suspend_synapse_sql_pool.name

  # The parameter names need to be specified in lowercase only. See: "https://github.com/Azure/azure-sdk-for-go/issues/4780
  parameters = {
    subscriptionid    = "${data.azurerm_client_config.client_config.subscription_id}"
    resourcegroupname = "${azurerm_resource_group.this.name}"
    workspacename     = "${azurerm_synapse_workspace.this.name}"
    sqlpoolname       = "${each.value.name}"
  }
}
