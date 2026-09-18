variable "deployment_account_id" {
  description = "AWS account that owns the GitHub Actions deployment role."
  type        = string
  default     = "242668368155"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.deployment_account_id))
    error_message = "Deployment account ID must be a 12-digit AWS account ID."
  }
}
