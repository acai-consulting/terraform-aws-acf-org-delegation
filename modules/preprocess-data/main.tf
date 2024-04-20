locals {
  # Assuming local.default_regions is defined somewhere else in your Terraform configuration
  regions_flattened = distinct(flatten([
    for delegation in var.delegations : delegation.regions
  ]))

  delegated_administrators = [
    for delegation in var.delegations :
    {
      service_principal = delegation.service_principal,
      target_account_id = delegation.target_account_id
    }
  ]

  delegations_by_region = {
    for region in local.regions_flattened : region => [
      for delegation in var.delegations :
      {
        service_principal   = delegation.service_principal,
        target_account_id   = delegation.target_account_id
        aggregation_region  = delegation.aggregation_region
        additional_settings = delegation.additional_settings
      } if contains(delegation.regions, region)
    ]
  }

  excepted_service_principals = [
    "stacksets.cloudformation.amazonaws.com"
  ]

  aws_service_access_principals = distinct(concat(
    [for access_principal in var.additional_aws_service_access_principals : access_principal if contains(local.excepted_service_principals, access_principal) == false],
    [for delegation in var.delegations : delegation.service_principal if contains(local.excepted_service_principals, delegation.service_principal) == false]
  ))
}
