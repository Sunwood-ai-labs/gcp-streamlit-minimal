output "streamlit_url" {
  description = "URL for the Streamlit application"
  value       = "http://${module.gce_instance.network_interface_details[0].access_config[0].nat_ip}:${var.streamlit_port}"
}

output "instance_ip" {
  description = "External IP address of the Compute Engine instance"
  value       = module.gce_instance.network_interface_details[0].access_config[0].nat_ip
}
