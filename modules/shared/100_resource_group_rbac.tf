locals {
  rbac_resource_group = flatten([
    for security_group_key, security_group in var.security_groups : [
      for object_key, object_id in security_group.object_ids : [
        for role_key, role in security_group.role_assignments.resource_group : [
          for resource_key, resource in toset([azurerm_resource_group.network, azurerm_resource_group.mgmt]) : {
            key                = "${lower(replace(security_group.name, " ", "_"))}.${lower(replace(role, " ", "_"))}.${lower(replace(resource.name, " ", "_"))}.${object_key}"
            security_group_key = security_group_key
            role_key           = role_key
            resource_key       = resource_key
            name               = security_group.name
            object_id          = object_id
            role               = role
            scope              = resource.id
          }
        ]
      ]
    ]
  ])
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "resource_group" {
  for_each = {
    for o in local.rbac_resource_group : o.key => o
  }

  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = each.value.object_id
}
