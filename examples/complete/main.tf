# ---------------------------------------------------------------------------------------------------------------------
# ¦ VERSIONS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.0"

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
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE
# ---------------------------------------------------------------------------------------------------------------------

locals {
  default_regions = ["eu-central-1", "us-east-2"]
  delegations = [
    {
      service_principal = "fms.amazonaws.com"
      target_account_id = "992382728088" // core_security
      regions = ["us-east-1"]
    },
    {
      service_principal = "guardduty.amazonaws.com"
      target_account_id = "992382728088" // core_security
      regions = local.default_regions 
    },
    {
      service_principal = "securityhub.amazonaws.com"
      target_account_id = "992382728088" // core_security
      regions = local.default_regions
    },
    {
      service_principal = "cloudtrail.amazonaws.com"
      target_account_id = "992382728088" // core_security
      regions = local.default_regions
    }
  ]
  aws_service_access_principals = [for delegation in local.delegations : delegation.service_principal]


}

module "preprocess_data" {
  source = "../../modules/preprocess-data"
  delegations = local.delegations
}


# in case you have an already existing AWS Organization with delegationst
import {
  to = module.example_global.aws_organizations_organization.org_mgmt_root[0]
  id = "o-5l2vzue7ku"
}
module "example_global" {
  source = "../../"

  organization_settings = {
    aws_service_access_principals = local.aws_service_access_principals
  }
  aws_organizations_resource_policy_json = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowOrganizationsRead",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::590183833356:root"
        },
        "Action" : [
          "organizations:Describe*",
          "organizations:List*"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowBackupPoliciesCreation",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::590183833356:root"
        },
        "Action" : "organizations:CreatePolicy",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "organizations:PolicyType" : "BACKUP_POLICY"
          }
        }
      }
    ]
  })
  delegated_administrators = module.preprocess_data.delegated_administrators
  providers = {
    aws = aws.org_mgmt_use1
  }
}

/*
import {
  to = module.example_euc1.aws_securityhub_organization_admin_account.securityhub[0]
  id = "992382728088"
}
import {
  to = module.example_euc1.aws_guardduty_detector.guardduty[0]
  id = "92c77b63215272adb2a40c5e233be655"
}*/
module "example_euc1" {
  source = "../../modules/regional"

  delegations = module.preprocess_data.delegations_by_region["eu-central-1"]
  depends_on = [
    module.example_global
  ]
  providers = {
    aws = aws.org_mgmt_euc1
  }
}

import {
  to = module.example_use1.aws_fms_admin_account.fms[0]
  id = "992382728088"
}
module "example_use1" {
  source = "../../modules/regional"

  delegations = module.preprocess_data.delegations_by_region["us-east-1"]
  depends_on = [
    module.example_global
  ]
  providers = {
    aws = aws.org_mgmt_use1
  }
}

module "example_use2" {
  source = "../../modules/regional"

  delegations = module.preprocess_data.delegations_by_region["us-east-2"]
  depends_on = [
    module.example_global
  ]
  providers = {
    aws = aws.org_mgmt_use2
  }
}