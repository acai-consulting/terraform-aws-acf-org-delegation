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
      regions = ["us-east-1"]
      service_principal = "fms.amazonaws.com"
      target_account_id = "992382728088" // core_security
    },
    {
      regions = local.default_regions 
      service_principal = "guardduty.amazonaws.com"
      target_account_id = "992382728088" // core_security      
    },
    {
      regions = local.default_regions
      service_principal = "securityhub.amazonaws.com"
      target_account_id = "992382728088" // core_security
      additional_settings = {
        auto_enable = true
      }
    },
    {
      regions = local.default_regions 
      service_principal = "cloudtrail.amazonaws.com"
      target_account_id = "992382728088" // core_security
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

module "example_euc1" {
  source = "../../"

  delegations = module.preprocess_data.delegations_by_region["eu-central-1"]
  providers = {
    aws = aws.org_mgmt_euc1
  }
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


module "example_use2" {
  source = "../../"

  delegations = module.preprocess_data.delegations_by_region["us-east-2"]
  providers = {
    aws = aws.org_mgmt_use2
  }
}