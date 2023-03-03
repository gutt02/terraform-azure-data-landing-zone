# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_spark_pool
resource "azurerm_synapse_spark_pool" "this" {
  for_each = {
    for o in var.synapse_workspace.spark_pools : lower(replace(o.name, " ", "_")) => o if var.synapse_workspace.spark_pools != null
  }

  name                 = each.value.name
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  node_size_family     = each.value.node_size_family
  node_size            = each.value.node_size

  auto_pause {
    delay_in_minutes = each.value.auto_pause_delay_in_minutes
  }

  auto_scale {
    max_node_count = each.value.auto_scale_max_node_count
    min_node_count = each.value.auto_scale_min_node_count
  }

  cache_size    = each.value.cache_size
  spark_version = each.value.spark_version

  #   library_requirement {
  #     content  = <<EOF
  # appnope==0.1.0
  # beautifulsoup4==4.6.3
  # EOF
  #     filename = "requirements.txt"
  #   }

  #   spark_config {
  #     content  = <<EOF
  # spark.shuffle.spill                true
  # EOF
  #     filename = "config.txt"
  #   }
}
