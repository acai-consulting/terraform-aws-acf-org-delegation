variable "primary_aws_region" {
  description = "Explicitly decide if this is the primary AWS Regin. May only be done for one region."
  type        = bool
  default     = false
}

variable "delegations" {
  description = "List of delegations specifying the target account ID and service principal for AWS Organizations Delegated Administrators."
  type = list(object({
    service_principal : string # https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html
    target_account_id : string
    aggregation_region : optional(string)
    additional_settings = optional(map(string))
  }))
  default = []

  validation {
    condition     = alltrue([for d in var.delegations : can(regex("^\\d{12}$", d.target_account_id))])
    error_message = "Each 'target_account_id' must be a 12-digit AWS account ID."
  }
}

variable "aws_organizations_resource_policy" {
  description = "JSON of the AWS Organizations Delegation. Ensure this is only specified in one instance of this module"
  type        = object({
    content_as_json = string
    resource_tags = optional(map(string))
  })
  default     = null
}