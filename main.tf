/*
special delegated admistration configurations for

auditmanager.amazonaws.com
config.amazonaws.com
securityhub.amazonaws.com
guardduty.amazonaws.com
detective.amazonaws.com
inspector2.amazonaws.com
fms.amazonaws.com

pending:
backup.amazonaws.com
*/
# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.30"
      configuration_aliases = []
    }
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_region" "current" {}

locals {
  is_use1 = data.aws_region.current.name == "us-east-1"
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ AWS ORGANIZATIONS RESOURCE POLICY
# ---------------------------------------------------------------------------------------------------------------------
# See: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies.html
# This is a global resource - marke sure you specify it only once
resource "aws_organizations_resource_policy" "aws_organizations_resource_policy" {
  count = var.aws_organizations_resource_policy_json == null ? 0 : 1

  content = var.aws_organizations_resource_policy_json
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATIONS
# ---------------------------------------------------------------------------------------------------------------------
# See: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html?icmpid=docs_orgs_console
locals {
  special_delegations = []
/*    "auditmanager.amazonaws.com",
    "config.amazonaws.com",
    "securityhub.amazonaws.com",
    "guardduty.amazonaws.com",
    "detective.amazonaws.com",
    "inspector2.amazonaws.com",
    "fms.amazonaws.com",
    "ipam.amazonaws.com",
    "macie.amazonaws.com",
  ]*/
  common_delegations = [for delegation in var.delegations :
    {
      service_principal = delegation.service_principal,
      target_account_id = delegation.target_account_id
    } if !contains(local.special_delegations, delegation.service_principal)
  ]
}

resource "aws_organizations_delegated_administrator" "delegations" {
  for_each = { for del in local.common_delegations : "${del.target_account_id}/${del.service_principal}" => del }

  account_id        = each.value.target_account_id
  service_principal = each.value.service_principal
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - auditmanager.amazonaws.com
# ---------------------------------------------------------------------------------------------------------------------
locals {
  auditmanager_delegation       = contains([for d in var.delegations : d.service_principal], "auditmanager.amazonaws.com")
  auditmanager_admin_account_id = try([for d in var.delegations : d.target_account_id if d.service_principal == "auditmanager.amazonaws.com"][0], null)
}

resource "aws_auditmanager_organization_admin_account_registration" "auditmanager" {
  count = local.auditmanager_delegation ? 1 : 0

  admin_account_id = local.auditmanager_admin_account_id
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - config.amazonaws.com
# ---------------------------------------------------------------------------------------------------------------------
locals {
  config_delegation         = contains([for d in var.delegations : d.service_principal], "config.amazonaws.com")
  config_admin_account_id   = try([for d in var.delegations : d.target_account_id if d.service_principal == "config.amazonaws.com"][0], null)
  config_aggregation_region = try([for d in var.delegations : d.aggregation_region if d.service_principal == "config.amazonaws.com"][0], null)
}

resource "aws_config_aggregate_authorization" "config_delegation" {
  count = local.config_delegation ? 1 : 0

  account_id = local.config_admin_account_id
  region     = local.config_aggregation_region
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - securityhub.amazonaws.com
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_admin_account
# https://docs.aws.amazon.com/securityhub/latest/userguide/central-configuration-intro.html
# ---------------------------------------------------------------------------------------------------------------------
locals {
  securityhub_delegation       = contains([for d in var.delegations : d.service_principal], "securityhub.amazonaws.com")
  securityhub_admin_account_id = try([for d in var.delegations : d.target_account_id if d.service_principal == "securityhub.amazonaws.com"][0], null)
}

resource "aws_securityhub_account" "securityhub" {
  count = local.securityhub_delegation ? 1 : 0

  lifecycle {
    ignore_changes = [
      control_finding_generator # https://github.com/hashicorp/terraform-provider-aws/issues/30980
    ]
  }
  depends_on = [ aws_organizations_delegated_administrator.delegations ]
}

resource "aws_securityhub_organization_admin_account" "securityhub" {
  count = local.securityhub_delegation ? 1 : 0

  admin_account_id = local.securityhub_admin_account_id
  depends_on = [ aws_securityhub_account.securityhub ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - guardduty.amazonaws.com
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account
# ---------------------------------------------------------------------------------------------------------------------
locals {
  guardduty_delegation       = contains([for d in var.delegations : d.service_principal], "guardduty.amazonaws.com")
  guardduty_admin_account_id = try([for d in var.delegations : d.target_account_id if d.service_principal == "guardduty.amazonaws.com"][0], null)
}

resource "aws_guardduty_detector" "guardduty" {
  #checkov:skip=CKV2_AWS_3
  count = local.guardduty_delegation ? 1 : 0
  depends_on = [ aws_organizations_delegated_administrator.delegations ]
}

resource "aws_guardduty_organization_admin_account" "guardduty" {
  count = local.guardduty_delegation ? 1 : 0

  admin_account_id = local.guardduty_admin_account_id
  depends_on = [ aws_guardduty_detector.guardduty ]
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - detective.amazonaws.com
# ---------------------------------------------------------------------------------------------------------------------
locals {
  detective_delegation       = contains([for d in var.delegations : d.service_principal], "detective.amazonaws.com")
  detective_admin_account_id = try([for d in var.delegations : d.target_account_id if d.service_principal == "detective.amazonaws.com"][0], null)
}

resource "aws_detective_organization_admin_account" "detective" {
  count = local.detective_delegation ? 1 : 0

  account_id = local.detective_admin_account_id
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - inspector2.amazonaws.com
# ---------------------------------------------------------------------------------------------------------------------
locals {
  inspector_delegation       = contains([for d in var.delegations : d.service_principal], "inspector2.amazonaws.com")
  inspector_admin_account_id = try([for d in var.delegations : d.target_account_id if d.service_principal == "inspector2.amazonaws.com"][0], null)
}

resource "aws_inspector2_delegated_admin_account" "inspector" {
  count = local.inspector_delegation ? 1 : 0

  account_id = local.inspector_admin_account_id
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - fms.amazonaws.com
# once delegated, it can only be revoked from the delegated account
# ---------------------------------------------------------------------------------------------------------------------
locals {
  fms_delegation       = contains([for d in var.delegations : d.service_principal], "fms.amazonaws.com")
  fms_admin_account_id = try([for d in var.delegations : d.target_account_id if d.service_principal == "fms.amazonaws.com"][0], null)
}

resource "aws_fms_admin_account" "fms" {
  count = local.fms_delegation ? 1 : 0

  account_id = local.fms_admin_account_id
  lifecycle {
    precondition {
      condition     = local.is_use1
      error_message = "FMS can only be delegated in 'us-east-1'. Current provider region is '${data.aws_region.current.name}'."
    }
    ignore_changes = [
      account_id, # Adding this to ignore changes in account_id during applies and destroys
    ]
    prevent_destroy = false
  }
}
