# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace
resource "azurerm_databricks_workspace" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-dbws"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  custom_parameters {
    no_public_ip                                         = true
    # no_public_ip                                         = false
    private_subnet_name                                  = var.subnet_databricks_private_name
    private_subnet_network_security_group_association_id = var.network_security_group_association_databricks_private_id
    public_subnet_name                                   = var.subnet_databricks_public_name
    public_subnet_network_security_group_association_id  = var.network_security_group_association_databricks_public_id
    storage_account_name                                 = "${var.project.customer}${var.project.name}${var.project.environment}sadbws"
    virtual_network_id                                   = var.virtual_network_id
  }

  managed_resource_group_name           = "${var.project.customer}-${var.project.name}-${var.project.environment}-rg-shared-databricks"
  network_security_group_rules_required = "NoAzureDatabricksRules"
  public_network_access_enabled         = false
  # public_network_access_enabled         = true
  sku                                   = "premium"
}
