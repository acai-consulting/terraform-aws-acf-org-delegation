/*
special delegated admistration configurations for

auditmanager.amazonaws.com
config.amazonaws.com
securityhub.amazonaws.com
guardduty.amazonaws.com
detective.amazonaws.com
inspector2.amazonaws.com
fms.amazonaws.com
ipam.amazonaws.com
macie.amazonaws.com


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
# ¦ DELEGATION - auditmanager.amazonaws.com
# ---------------------------------------------------------------------------------------------------------------------
locals {
  auditmanager_delegation = contains([for d in var.delegations : d.service_principal], "auditmanager.amazonaws.com")
  auditmanager_admin_account_id = try([for d in var.delegations : d.target_account_id if  d.service_principal == "auditmanager.amazonaws.com"][0],  null)
}

resource "aws_auditmanager_organization_admin_account_registration" "auditmanager" {
  count = local.auditmanager_delegation ? 1 : 0

  admin_account_id = local.auditmanager_admin_account_id
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - config.amazonaws.com
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
# ¦ DELEGATION - securityhub.amazonaws.com
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
# ¦ DELEGATION - detective.amazonaws.com
# ---------------------------------------------------------------------------------------------------------------------
locals {
  detective_delegation = contains([for d in var.delegations : d.service_principal], "detective.amazonaws.com")
  detective_admin_account_id = try([for d in var.delegations : d.target_account_id if  d.service_principal == "detective.amazonaws.com"][0],  null)
}

resource "aws_detective_organization_admin_account" "detective" {
  account_id = local.detective_admin_account_id
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - inspector2.amazonaws.com
# ---------------------------------------------------------------------------------------------------------------------
locals {
  inspector_delegation = contains([for d in var.delegations : d.service_principal], "inspector2.amazonaws.com")
  inspector_admin_account_id = try([for d in var.delegations : d.target_account_id if  d.service_principal == "inspector2.amazonaws.com"][0],  null)
}

resource "aws_inspector2_delegated_admin_account" "inspector" {
  count = local.inspector_delegation ? 1 : 0

  account_id = local.inspector_admin_account_id
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - fms.amazonaws.com
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


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - ipam.amazonaws.com
# ---------------------------------------------------------------------------------------------------------------------
locals {
  ipam_delegation = contains([for d in var.delegations : d.service_principal], "ipam.amazonaws.com")
  ipam_admin_account_id = try([for d in var.delegations : d.target_account_id if  d.service_principal == "ipam.amazonaws.com"][0],  null)
}

resource "aws_vpc_ipam_organization_admin_account" "ipam" {
  count = local.ipam_delegation ? 1 : 0

  delegated_admin_account_id  = local.ipam_admin_account_id
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATION - macie.amazonaws.com
# ---------------------------------------------------------------------------------------------------------------------
locals {
  macie_delegation = contains([for d in var.delegations : d.service_principal], "macie.amazonaws.com")
  macie_admin_account_id = try([for d in var.delegations : d.target_account_id if  d.service_principal == "macie.amazonaws.com"][0],  null)
}

resource "aws_macie2_account" "macie" {
  count = local.macie_delegation ? 1 : 0
}

resource "aws_macie2_organization_admin_account" "macie" {
  count = local.macie_delegation ? 1 : 0

  admin_account_id = local.macie_admin_account_id
  depends_on       = [
    aws_macie2_account.macie
  ]
}