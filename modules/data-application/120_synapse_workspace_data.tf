# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources
data "azurerm_resources" "storage_account_reference" {
  type = "Microsoft.Storage/storageAccounts"

  required_tags = {
    linked_service = "enabled"
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account
data "azurerm_storage_account" "storage_account" {
  count = length(data.azurerm_resources.storage_account_reference.resources)

  name                = data.azurerm_resources.storage_account_reference.resources[count.index].name
  resource_group_name = element(split("/", data.azurerm_resources.storage_account_reference.resources[count.index].id), 4)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources
data "azurerm_resources" "mssql_server_reference" {
  type = "Microsoft.Sql/servers"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/mssql_server
data "azurerm_mssql_server" "mssql_server" {
  count = length(data.azurerm_resources.mssql_server_reference.resources)

  name                = data.azurerm_resources.mssql_server_reference.resources[count.index].name
  resource_group_name = element(split("/", data.azurerm_resources.mssql_server_reference.resources[count.index].id), 4)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources
data "azurerm_resources" "database_reference" {
  type = "Microsoft.Sql/servers/databases"

  required_tags = {
    linked_service = "enabled"
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/mssql_database
data "azurerm_mssql_database" "database" {
  count = length(data.azurerm_resources.database_reference.resources)

  # remove everything before the slash (including) to extract the Azure SQL Database name
  name = replace(data.azurerm_resources.database_reference.resources[count.index].name, "/.*[/]/", "")
  # remove everything after databases (including) to extract the Azure SQL Server Id
  server_id = replace(data.azurerm_resources.database_reference.resources[count.index].id, "/[/]databases[/].*/", "")
}

locals {
  database = flatten([
    for mssql_server_key, mssql_server in data.azurerm_mssql_server.mssql_server : [
      for mssql_database_key, mssql_database in data.azurerm_mssql_database.database : {
        key                = "${lower(replace(mssql_server.name, " ", "_"))}.${lower(replace(mssql_database.name, " ", "_"))}"
        mssql_server_key   = mssql_server_key
        mssql_database_key = mssql_database_key
        mssql_server       = mssql_server
        mssql_database     = mssql_database
      } if mssql_database.server_id == mssql_server.id
    ]
  ])
}
