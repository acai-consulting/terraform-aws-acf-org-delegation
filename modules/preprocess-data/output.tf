output "delegated_administrators" {
  description = "List of delegated admins."
  value = local.delegated_administrators
}

output "delegations_by_region" {
  description = "List of delegations per region."
  value = local.delegations_by_region
}

// https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html
output "aws_service_access_principals" {
  description = "Consolidated distinct list of aws_service_access_principals"
  value = local.aws_service_access_principals
}


