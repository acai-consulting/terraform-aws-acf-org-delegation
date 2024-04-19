variable "organization_settings" {
  description = "AWS Organization Settings."
  type = object({
    additional_aws_service_access_principals : optional(list(string), []) // https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html
    enabled_policy_types : optional(list(string), ["SERVICE_CONTROL_POLICY"])
    feature_set : optional(string, "ALL")
  })
  default = {
    additional_aws_service_access_principals = []
    enabled_policy_types                     = ["SERVICE_CONTROL_POLICY"]
    feature_set                              = "ALL"
  }
}

variable "aws_organizations_resource_policy_json" {
  description = "JSON of the AWS Organizations Delegation."
  type        = string
  default     = null
}

variable "delegations" {
  description = "List of delegations specifying the target account ID and service principal for AWS Organizations Delegated Administrators."
  type = list(object({
    service_principal : string // https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html
    target_account_id : string
  }))
  default = []

  validation {
    condition     = alltrue([for d in var.delegations : can(regex("^\\d{12}$", d.target_account_id))])
    error_message = "Each 'target_account_id' must be a 12-digit AWS account ID."
  }
}
