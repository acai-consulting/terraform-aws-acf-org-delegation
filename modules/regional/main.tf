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
# ¦ DELEGATION - AWS CONFIG
# ---------------------------------------------------------------------------------------------------------------------
locals {
  config_delegation = contains([for d in var.delegations : d.service_principal], "config.amazonaws.com")
  config_admin_account_id = try([for d in var.delegations : d.target_account_id if  d.service_principal == "config.amazonaws.com"][0],  null)
  config_aggregation_region = try([for d in var.delegations : d.aggregation_region if  d.service_principal == "config.amazonaws.com"][0],  null)
}

resource "aws_config_aggregate_authorization" "config_delegation" {
  count = local.config_delegation ? 1 : 0

  account_id = local.config_admin_account_id
  region     = local.config_aggregation_region
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
}