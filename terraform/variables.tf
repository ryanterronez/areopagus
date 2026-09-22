variable "audio_noncurrent_version_expiration_days" {
  description = "Number of days to retain superseded audio object versions."
  type        = number
  default     = 30

  validation {
    condition     = var.audio_noncurrent_version_expiration_days >= 1
    error_message = "Audio noncurrent version expiration must be at least one day."
  }
}

variable "assume_local_terraform_role" {
  description = "Whether the AWS provider assumes the local Terraform role."
  type        = bool
  default     = true
}
