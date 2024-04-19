# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
      configuration_aliases = [
      ]
    }
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_region" "current" {}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ BASIC SETTINGS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  org_mgmt_root = var.organization_settings == null ? data.aws_organizations_organization.org_mgmt_root[0] : aws_organizations_organization.org_mgmt_root[0]
}
resource "aws_organizations_organization" "org_mgmt_root" {
  count = var.organization_settings == null ? 0 : 1
  aws_service_access_principals = var.organization_settings.aws_service_access_principals
  enabled_policy_types          = var.organization_settings.enabled_policy_types
  feature_set                   = var.organization_settings.feature_set
  lifecycle {
    prevent_destroy = true
  }
}

data "aws_organizations_organization" "org_mgmt_root" {
  count = var.organization_settings == null ? 1 : 0
}

# See: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies.html
resource "aws_organizations_resource_policy" "aws_organizations_resource_policy" {
  count = var.aws_organizations_resource_policy_json == null ? 0 : 1
  content = var.aws_organizations_resource_policy_json
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATIONS
# ---------------------------------------------------------------------------------------------------------------------
# See: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html?icmpid=docs_orgs_console
resource "aws_organizations_delegated_administrator" "delegations" {
  for_each = { for del in var.delegated_administrators : "${del.service_principal}:${del.target_account_id}" => del }

  account_id        = each.value.target_account_id
  service_principal = each.value.service_principal
  depends_on = [
    local.org_mgmt_root
  ]
}

