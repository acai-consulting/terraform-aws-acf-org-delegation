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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_delegation"></a> [delegation](#module\_delegation) | ./modules/delegation | n/a |
| <a name="module_ou_structure"></a> [ou\_structure](#module\_ou\_structure) | ./modules/ou-structure | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_organizations_organization.organization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_delegations"></a> [delegations](#input\_delegations) | List of delegations specifying the target account ID and service principal for AWS Organizations Delegated Administrators. | <pre>list(object({<br>    target_account_id : string<br>    service_principal : string<br>  }))</pre> | `[]` | no |
| <a name="input_organizational_units"></a> [organizational\_units](#input\_organizational\_units) | The organization with the tree of organizational units and their tags. | <pre>object({<br>    level1_units = optional(list(object({<br>      name    = string,<br>      scp_ids = optional(list(string), [])<br>      tags    = optional(map(string), {}),<br>      level2_units = optional(list(object({<br>        name    = string,<br>        scp_ids = optional(list(string), [])<br>        tags    = optional(map(string), {}),<br>        level3_units = optional(list(object({<br>          name    = string,<br>          scp_ids = optional(list(string), [])<br>          tags    = optional(map(string), {}),<br>          level4_units = optional(list(object({<br>            name    = string,<br>            scp_ids = optional(list(string), [])<br>            tags    = optional(map(string), {}),<br>            level5_units = optional(list(object({<br>              name    = string,<br>              scp_ids = optional(list(string), [])<br>              tags    = optional(map(string), {}),<br>            })), [])<br>          })), [])<br>        })), [])<br>      })), [])<br>    })), [])<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_delegation"></a> [delegation](#output\_delegation) | List of delegations. |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | The ID of the AWS Organization. |
| <a name="output_ou_structure"></a> [ou\_structure](#output\_ou\_structure) | List of provisioned OUs. |
| <a name="output_root_ou_id"></a> [root\_ou\_id](#output\_root\_ou\_id) | The ID of the root organizational unit. |
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