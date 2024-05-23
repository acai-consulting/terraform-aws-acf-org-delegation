output "delegations" {
  description = "List of AWS Organizations Delegated Administrators created."
  value = [for del in aws_organizations_delegated_administrator.delegations : {
    account_id        = del.account_id
    service_principal = del.service_principal
  }]
}

output "resource_tags" {
  description = "resource_tags"
  value = local.resource_tags
}

