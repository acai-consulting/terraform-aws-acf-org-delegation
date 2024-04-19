variable "organization_settings" {
  description = "AWS Organization Settings."
  type = object({
    aws_service_access_principals : optional(list(string), []) // https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html
    enabled_policy_types : optional(list(string), ["SERVICE_CONTROL_POLICY"])
    feature_set : optional(string, "ALL")
  })

  validation {
    # Validate that the enabled policy types only contain known values
    condition = alltrue([
      for policy_type in var.organization_settings.enabled_policy_types : 
      contains(["SERVICE_CONTROL_POLICY", "TAG_POLICY", "BACKUP_POLICY"], policy_type)
    ])
    error_message = "Enabled policy types must be one or more of 'SERVICE_CONTROL_POLICY', 'TAG_POLICY', 'BACKUP_POLICY'."
  }

  validation {
    # Validate that the feature set is either "ALL" or "CONSOLIDATED_BILLING"
    condition = contains(["ALL", "CONSOLIDATED_BILLING"], var.organization_settings.feature_set)
    error_message = "Feature set must be 'ALL' or 'CONSOLIDATED_BILLING'."
  }  
}

variable "aws_organizations_resource_policy_json" {
  description = "JSON of the AWS Organizations Delegation."
  type        = string
  default     = null
}

variable "delegated_administrators" {
  description = "List of delegations specifying the target account ID and service principal for AWS Organizations Delegated Administrators."
  type = list(object({
    service_principal : string // https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html
    target_account_id : string
  }))
  default = []

  validation {
    condition     = alltrue([for d in var.delegated_administrators : can(regex("^\\d{12}$", d.target_account_id))])
    error_message = "Each 'target_account_id' must be a 12-digit AWS account ID."
  }
}
