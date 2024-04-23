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
# ¦ CREATE PROVISIONER
# ---------------------------------------------------------------------------------------------------------------------
module "create_provisioner" {
  source = "../../cicd-principals/terraform"

  iam_role_settings = {
    name = "cicd_provisioner"
    aws_trustee_arns = [
      "arn:aws:iam::471112796356:root",
      "arn:aws:iam::471112796356:user/tfc_provisioner"
    ]
  }
  providers = {
    aws = aws.org_mgmt
  }
}

provider "aws" {
  profile = "acai_testbed"
  region  = "eu-central-1"
  alias   = "org_mgmt_euc1"
  assume_role {
    role_arn = module.create_provisioner.iam_role_arn
  }
}

provider "aws" {
  profile = "acai_testbed"
  region  = "us-east-1"
  alias   = "org_mgmt_use1"
  assume_role {
    role_arn = module.create_provisioner.iam_role_arn
  }
}

provider "aws" {
  profile = "acai_testbed"
  region  = "us-east-2"
  alias   = "org_mgmt_use2"
  assume_role {
    role_arn = module.create_provisioner.iam_role_arn
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE
# ---------------------------------------------------------------------------------------------------------------------

locals {
  primary_aws_region = "eu-central-1"
  default_regions    = ["eu-central-1", "us-east-2"]
  delegations = [
    {
      regions           = ["us-east-1"]
      service_principal = "cloudtrail.amazonaws.com"
      target_account_id = "992382728088" # core_security
    },
    {
      regions           = local.default_regions
      service_principal = "guardduty.amazonaws.com"
      target_account_id = "992382728088" # core_security      
    },
    {
      regions           = local.default_regions
      service_principal = "securityhub.amazonaws.com"
      target_account_id = "992382728088" # core_security
    },
    {
      regions           = [local.primary_aws_region]
      service_principal = "backup.amazonaws.com"
      target_account_id = "992382728088" # core_security
    },
    {
      regions           = [local.primary_aws_region]
      service_principal = "member.org.stacksets.cloudformation.amazonaws.com"
      target_account_id = "992382728088" # core_security
    },
    {
      regions           = [local.primary_aws_region]
      service_principal = "member.org.stacksets.cloudformation.amazonaws.com"
      target_account_id = "590183833356" # core_logging
    }

  ]
}

module "preprocess_data" {
  source      = "../../modules/preprocess-data"
  delegations = local.delegations
}

module "example_euc1" {
  source = "../../"

  delegations        = module.preprocess_data.delegations_by_region["eu-central-1"]
  primary_aws_region = true
  providers = {
    aws = aws.org_mgmt_euc1
  }
  depends_on = [module.create_provisioner]
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
  primary_aws_region = false
  providers = {
    aws = aws.org_mgmt_use1
  }
  depends_on = [
    module.create_provisioner,
    module.example_euc1
  ]
}

module "example_use2" {
  source = "../../"

  delegations        = module.preprocess_data.delegations_by_region["us-east-2"]
  primary_aws_region = false
  providers = {
    aws = aws.org_mgmt_use2
  }
  depends_on = [
    module.create_provisioner,
    module.example_euc1
  ]
}