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
variable "downloader_ephemeral_storage_mb" {
  description = "Ephemeral storage available for the downloaded source audio."
  type        = number
  default     = 2048

  validation {
    condition     = var.downloader_ephemeral_storage_mb >= 512 && var.downloader_ephemeral_storage_mb <= 10240
    error_message = "Downloader ephemeral storage must be between 512 and 10240 MB."
  }
}

variable "downloader_memory_size_mb" {
  description = "Memory allocated to the downloader Lambda function."
  type        = number
  default     = 1024

  validation {
    condition     = var.downloader_memory_size_mb >= 128 && var.downloader_memory_size_mb <= 10240
    error_message = "Downloader memory must be between 128 and 10240 MB."
  }
}

variable "downloader_timeout_seconds" {
  description = "Maximum duration for a YouTube audio download."
  type        = number
  default     = 900

  validation {
    condition     = var.downloader_timeout_seconds >= 1 && var.downloader_timeout_seconds <= 900
    error_message = "Downloader timeout must be between 1 and 900 seconds."
  }
}
