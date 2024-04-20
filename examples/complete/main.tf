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
    },    
  ]
}

module "preprocess_data" {
  source = "../../modules/preprocess-data"
  delegations = local.delegations
  additional_aws_service_access_principals = [
    "stacksets.cloudformation.amazonaws.com"
  ]
}

import {
  to = module.example_euc1.aws_securityhub_organization_admin_account.securityhub[0]
  id = "992382728088"
}
import {
  to = module.example_euc1.aws_guardduty_detector.guardduty[0]
  id = "90c77d2e9819eea01a714830cab690e1"
}
module "example_euc1" {
  source = "../../"

  delegations = module.preprocess_data.delegations_by_region["eu-central-1"]
  providers = {
    aws = aws.org_mgmt_euc1
  }
}

import {
  to = module.example_use1.aws_fms_admin_account.fms[0]
  id = "992382728088"
}
module "example_use1" {
  source = "../../"

  delegations = module.preprocess_data.delegations_by_region["us-east-1"]
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
  providers = {
    aws = aws.org_mgmt_use1
  }
}

import {
  to = module.example_use2.aws_securityhub_organization_admin_account.securityhub[0]
  id = "992382728088"
}
import {
  to = module.example_use2.aws_guardduty_detector.guardduty[0]
  id = "28c77d2e98f23d78fb16e74b8013720f"
}
module "example_use2" {
  source = "../../"

  delegations = module.preprocess_data.delegations_by_region["us-east-2"]
  providers = {
    aws = aws.org_mgmt_use2
  }
}