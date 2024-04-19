variable "delegations" {
  description = "List of delegations specifying the target account ID and service principal for AWS Organizations Delegated Administrators."
  type = list(object({
    service_principal : string // https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html
    target_account_id : string
    aggregation_region : optional(string)
  }))
  default = []

  validation {
    condition     = alltrue([for d in var.delegations : can(regex("^\\d{12}$", d.target_account_id))])
    error_message = "Each 'target_account_id' must be a 12-digit AWS account ID."
  }
}