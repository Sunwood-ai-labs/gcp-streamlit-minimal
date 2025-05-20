variable "instance_name" {
  description = "Name of the Compute Engine instance."
  type        = string
}

variable "machine_type" {
  description = "Machine type for the instance."
  type        = string
}

variable "boot_disk_image" {
  description = "Image for the boot disk."
  type        = string
}

variable "boot_disk_size" {
  description = "Size of the boot disk in GB."
  type        = number
}

variable "network" {
  description = "Network to attach the instance to."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork to attach the instance to."
  type        = string
  default     = null # Allows using network's auto-create subnetwork
}

variable "tags" {
  description = "A list of network tags to apply to the instance."
  type        = list(string)
  default     = []
}

variable "service_account_scopes" {
  description = "List of service account scopes for the instance."
  type        = list(string)
  default     = ["cloud-platform"]
}

variable "metadata_startup_script" {
  description = "Startup script for the instance."
  type        = string
  default     = ""
}

variable "service_account_email" {
  description = "The email of the service account to be used by the instance. If null, the default Compute Engine service account is used."
  type        = string
  default     = null
}
