# terraform-aws-acf-ou-mgmt Terraform module

<!-- LOGO -->
<a href="https://acai.gmbh">    
  <img src="https://github.com/acai-consulting/acai.public/raw/main/logo/logo_github_readme.png" alt="acai logo" title="ACAI" align="right" height="75" />
</a>

<!-- SHIELDS -->
[![Maintained by acai.gmbh][acai-shield]][acai-url]
![module-version-shield]
![terraform-version-shield]
![trivy-shield]
![checkov-shield]
[![Latest Release][release-shield]][release-url]

<!-- DESCRIPTION -->
Manage your AWS Organization

[Terraform][terraform-url] module to deploy REPLACE_ME resources on [AWS][aws-url]

<!-- FEATURES -->
## Features

### Delegation



### OU-Structure

Will provision the AWS Organization Unit (OU) structure based on a given HCL map.

``` hcl
locals {
  # OU-Names are case-sensitive!!!
  organizational_units = {
    level1_units : [
      # Artificial Org Structure
      {
        name : "level1_unit1",
        level2_units : [
          {
            name : "level1_unit1__level2_unit1"
          },
          {
            name : "level1_unit1__level2_unit2",
            level3_units = [
              {
                name : "level1_unit1__level2_unit2__level3_unit1",
                tags : {
                  "key1" : "value 1",
                  "key2" : "value 2"
                }
              }
            ]
          }
        ]
      },
      {
        name : "level1_unit2",
        level2_units : [
          {
            name : "level1_unit2__level2_unit1"
          },
          {
            name : "level1_unit2__level2_unit2"
          },
          {
            name : "level1_unit2__level2_unit3"
          }
        ]
      }
    ]
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.30 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.30 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_auditmanager_organization_admin_account_registration.auditmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/auditmanager_organization_admin_account_registration) | resource |
| [aws_config_aggregate_authorization.config_delegation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_aggregate_authorization) | resource |
| [aws_detective_organization_admin_account.detective](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/detective_organization_admin_account) | resource |
| [aws_fms_admin_account.fms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fms_admin_account) | resource |
| [aws_guardduty_detector.guardduty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | resource |
| [aws_guardduty_organization_admin_account.guardduty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource |
| [aws_inspector2_delegated_admin_account.inspector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_delegated_admin_account) | resource |
| [aws_organizations_delegated_administrator.delegations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_delegated_administrator) | resource |
| [aws_organizations_resource_policy.aws_organizations_resource_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_resource_policy) | resource |
| [aws_securityhub_account.securityhub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_organization_admin_account.securityhub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_admin_account) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_organizations_resource_policy_json"></a> [aws\_organizations\_resource\_policy\_json](#input\_aws\_organizations\_resource\_policy\_json) | JSON of the AWS Organizations Delegation. Ensure this is only specified in one instance of this module | `string` | `null` | no |
| <a name="input_delegations"></a> [delegations](#input\_delegations) | List of delegations specifying the target account ID and service principal for AWS Organizations Delegated Administrators. | <pre>list(object({<br>    service_principal : string # https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html<br>    target_account_id : string<br>    aggregation_region : optional(string)<br>    additional_settings = optional(map(string))<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_delegations"></a> [delegations](#output\_delegations) | List of AWS Organizations Delegated Administrators created. |
<!-- END_TF_DOCS -->

<!-- AUTHORS -->
## Authors

This module is maintained by [ACAI GmbH][acai-url].

<!-- LICENSE -->
## License

See [LICENSE][license-url] for full details.

<!-- MARKDOWN LINKS & IMAGES -->
[acai-shield]: https://img.shields.io/badge/maintained_by-acai.gmbh-CB224B?style=flat
[acai-url]: https://acai.gmbh
[module-version-shield]: https://img.shields.io/badge/module_version-1.1.4-CB224B?style=flat
[terraform-version-shield]: https://img.shields.io/badge/tf-%3E%3D1.3.0-blue.svg?style=flat&color=blueviolet
[trivy-shield]: https://img.shields.io/badge/trivy-passed-green
[checkov-shield]: https://img.shields.io/badge/checkov-passed-green
[release-shield]: https://img.shields.io/github/v/release/acai-consulting/terraform-aws-acf-ou-mgmt?style=flat&color=success
[release-url]: https://github.com/acai-consulting/terraform-aws-acf-ou-mgmt/releases
[license-url]: https://github.com/acai-consulting/terraform-aws-acf-ou-mgmt/tree/main/LICENSE.md
[terraform-url]: https://www.terraform.io
[aws-url]: https://aws.amazon.com
