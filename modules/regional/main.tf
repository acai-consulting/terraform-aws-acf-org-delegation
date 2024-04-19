# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
      configuration_aliases = []
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
  aws_service_access_principals = concat(
    var.organization_settings.additional_aws_service_access_principals,
    [for delegation in var.delegations : delegation.service_principal]
  )
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
  for_each = { for del in var.delegations : "${del.service_principal}:${del.target_account_id}" => del }

  account_id        = each.value.target_account_id
  service_principal = each.value.service_principal
  depends_on = [
    local.org_mgmt_root
  ]
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - SECURITY HUB
# ---------------------------------------------------------------------------------------------------------------------
locals {
  securityhub_delegation = contains([for d in var.delegations : d.service_principal], "securityhub.amazonaws.com")
  securityhub_admin_account_id = try([for d in var.delegations : d.target_account_id if  d.service_principal == "securityhub.amazonaws.com"][0],  null)
}

resource "aws_securityhub_account" "securityhub" {
  count = local.securityhub_delegation ? 1 : 0

  lifecycle {
    ignore_changes = [
      control_finding_generator // https://github.com/hashicorp/terraform-provider-aws/issues/30980
    ]
  }
}

resource "aws_securityhub_organization_admin_account" "securityhub" {
  count = local.securityhub_delegation ? 1 : 0

  admin_account_id = local.securityhub_admin_account_id
  depends_on       = [
    local.org_mgmt_root,
    aws_securityhub_account.securityhub
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - GUARDDUTY
# ---------------------------------------------------------------------------------------------------------------------
locals {
  guardduty_delegation = contains([for d in var.delegations : d.service_principal], "guardduty.amazonaws.com")
  guardduty_admin_account_id = try([for d in var.delegations : d.target_account_id if  d.service_principal == "guardduty.amazonaws.com"][0],  null)
}

resource "aws_guardduty_detector" "guardduty" {
  count = local.guardduty_delegation ? 1 : 0
}

resource "aws_guardduty_organization_admin_account" "guardduty" {
  count = local.guardduty_delegation ? 1 : 0

  admin_account_id = local.guardduty_admin_account_id
  depends_on       = [
    local.org_mgmt_root,
    aws_guardduty_detector.guardduty
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - FIREWALL MANAGER SERVICE
# ---------------------------------------------------------------------------------------------------------------------
locals {
  fms_delegation = contains([for d in var.delegations : d.service_principal], "fms.amazonaws.com")
  fms_admin_account_id = try([for d in var.delegations : d.target_account_id if  d.service_principal == "fms.amazonaws.com"][0],  null)
}

resource "aws_fms_admin_account" "fms" {
  count = local.fms_delegation ? 1 : 0

  account_id = local.fms_admin_account_id

  lifecycle {
    precondition {
      condition     = data.aws_region.current.name == "us-east-1"
      error_message = "FMS can only be delegated in 'us-east-1'. Current provider region is '${data.aws_region.current.name}'."
    }
  }
  depends_on = [
    local.org_mgmt_root
  ]
}