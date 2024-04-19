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

# in case you have an already existing AWS Organization 
import {
  to = module.example_complete.aws_organizations_organization.org_mgmt_root
  id = "o-5l2vzue7ku"
}
module "example_complete" {
  source = "../../"

  delegations = [
    {
      service_principal = "guardduty.amazonaws.com"
      target_account_id = "992382728088" // core_security
    },
    {
      service_principal = "fms.amazonaws.com"
      target_account_id = "992382728088" // core_security
    }    
  ]
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
    aws = aws.org_mgmt
  }
}
