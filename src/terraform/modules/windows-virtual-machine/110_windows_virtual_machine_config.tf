locals {
  update_time            = "06:00"
  update_date            = substr(time_offset.this.rfc3339, 0, 10)
  update_timezone        = "UTC"
  update_max_hours       = "4"
  update_classifications = "Critical, Security, UpdateRollup, ServicePack, Definition, Updates"
  update_reboot_settings = "IfRequired"
  update_day             = "Thursday"
  update_occurrence      = "2"
}

# https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/offset
resource "time_offset" "this" {
  offset_days = 1
}

# Shutdown virtual machine automatically
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_test_global_vm_shutdown_schedule
resource "azurerm_dev_test_global_vm_shutdown_schedule" "this" {
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  location           = var.location

  enabled = true

  daily_recurrence_time = "1700"
  timezone              = "UTC"

  notification_settings {
    enabled = false
  }
}

# https://learn.microsoft.com/en-us/cli/azure/vm/run-command?view=azure-cli-latest#az-vm-run-command-invoke
# https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource
# resource "null_resource" "mount_data_disk" {
#   provisioner "local-exec" {
#     command = "az vm run-command invoke --command-id RunPowerShellScript --name ${azurerm_windows_virtual_machine.this.name} -g ${azurerm_resource_group.this.name} --scripts @scripts/Add-DataDisk.ps1"
#   }

#   depends_on = [
#     azurerm_virtual_machine_data_disk_attachment.this
#   ]
# }

# New in Terraform 1.4.0
resource "terraform_data" "mount_data_disk" {
  provisioner "local-exec" {
    command = "az vm run-command invoke --command-id RunPowerShellScript --name ${azurerm_windows_virtual_machine.this.name} -g ${azurerm_resource_group.this.name} --scripts @scripts/Add-DataDisk.ps1"
  }

  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.this
  ]
}

# Install monitoring agent, needed for the automated patching
# https://learn.microsoft.com/de-de/azure/virtual-machines/extensions/oms-windows
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension
resource "azurerm_virtual_machine_extension" "this" {
  name                       = "MicrosoftMonitoringAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    "workspaceId" = "${var.log_analytics_workspace_id}"
  })

  protected_settings = jsonencode({
    "workspaceKey" = "${var.log_analytics_workspace_primary_shared_key}"
  })
}

# terraform is unable to destory (complete) this resource
# run it first then delete the item from the state file
# terraform state rm <resource_address>
# ATTENTION: Tests generate e-mails, SIC!
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_vm
# resource "azurerm_backup_protected_vm" "this" {
#   resource_group_name = azurerm_resource_group.this.name
#   recovery_vault_name = var.recovery_services_vault_name
#   source_vm_id        = azurerm_windows_virtual_machine.this.id
#   backup_policy_id    = "${var.recovery_services_vault_id}/backupPolicies/DefaultPolicy"

#   timeouts {
#     delete = "5m"
#   }

#   depends_on = [
#     azurerm_virtual_machine_extension.this,
#     null_resource.mount_data_disk
#   ]
# }

# https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep
resource "time_sleep" "delay_template_deployment" {
  depends_on = [
    azurerm_virtual_machine_extension.this,
    # null_resource.mount_data_disk
    terraform_data.mount_data_disk
  ]

  create_duration = "120s"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment
resource "azurerm_resource_group_template_deployment" "this" {
  name                = "windows-updates"
  resource_group_name = var.mgmt_resource_group_name

  deployment_mode = "Incremental"

  template_content = <<DEPLOY
  {
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "resources": [
      {
          "apiVersion": "2017-05-15-preview",
          "type": "Microsoft.Automation/automationAccounts/softwareUpdateConfigurations",
          "name": "${var.automation_account_name}/windows-updates",
          "properties": {
              "updateConfiguration": {
                  "operatingSystem": "Windows",
                  "duration": "PT${local.update_max_hours}H",
                  "windows": {
                      "excludedKbNumbers": [
                      ],
                      "includedUpdateClassifications": "${local.update_classifications}",
                      "rebootSetting": "${local.update_reboot_settings}"
                  },
                  "azureVirtualMachines": [
                      "${azurerm_windows_virtual_machine.this.id}"
                  ],
                  "nonAzureComputerNames": [
                  ]
              },
              "scheduleInfo": {
                  "frequency": "Month",
                  "startTime": "${local.update_date}T${local.update_time}:00",
                  "timeZone":  "${local.update_timezone}",
                  "interval": 1,
                  "advancedSchedule": {
                      "monthlyOccurrences": [
                          {
                            "occurrence": "${local.update_occurrence}",
                            "day": "${local.update_day}"
                          }
                      ]
                  }
              }
          }
      }
    ]
  }
  DEPLOY

  depends_on = [
    time_sleep.delay_template_deployment
  ]
}
