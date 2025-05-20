output "instance_id" {
  description = "The ID of the Compute Engine instance."
  value       = google_compute_instance.this.id
}

output "instance_name" {
  description = "The name of the Compute Engine instance."
  value       = google_compute_instance.this.name
}

output "network_interface_details" {
  description = "Details of the network interface of the instance."
  value       = google_compute_instance.this.network_interface
}

output "tags" {
  description = "Tags applied to the instance."
  value       = google_compute_instance.this.tags
}
