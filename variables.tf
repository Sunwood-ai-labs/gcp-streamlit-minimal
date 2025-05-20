variable "project_id" {
  description = "The ID of the GCP project."
  type        = string
  default     = "your-project-id"
}

variable "region" {
  description = "The region for GCP resources."
  type        = string
  default     = "asia-northeast1"
}

variable "zone" {
  description = "The zone for GCP resources."
  type        = string
  default     = "asia-northeast1-a"
}

variable "instance_name" {
  description = "The name of the Compute Engine instance."
  type        = string
  default     = "streamlit"
}

variable "machine_type" {
  description = "The machine type for the Compute Engine instance."
  type        = string
  default     = "e2-micro"
}

variable "image" {
  description = "The image for the Compute Engine instance's boot disk."
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "disk_size" {
  description = "The size of the boot disk in GB."
  type        = number
  default     = 10
}

variable "streamlit_port" {
  description = "The port for the Streamlit application."
  type        = number
  default     = 8501
}

variable "ssh_port" {
  description = "The port for SSH access."
  type        = number
  default     = 22
}
