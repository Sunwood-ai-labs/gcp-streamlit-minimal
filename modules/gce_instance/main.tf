# Defines a Google Compute Engine instance.
resource "google_compute_instance" "this" {
  project      = split("/", var.instance_name)[0] # Extracts project from instance_name if provided in format projects/PROJECT_ID/zones/ZONE_ID/instances/INSTANCE_NAME
  name         = var.instance_name      # Name of the Compute Engine instance.
  machine_type = var.machine_type # Machine type for the instance.
  tags         = var.tags             # Network tags applied to the instance.

  # Configures the boot disk for the instance.
  boot_disk {
    initialize_params {
      image = var.boot_disk_image # Image used for the boot disk.
      size  = var.boot_disk_size  # Size of the boot disk in GB.
    }
  }

  # Configures the network interface for the instance.
  network_interface {
    network    = var.network    # Network to attach the instance to.
    subnetwork = var.subnetwork # Subnetwork to attach the instance to.
    # access_config block to assign an ephemeral public IP address.
    access_config {
      # No specific configuration needed here for an ephemeral IP.
    }
  }

  # Configures the service account for the instance.
  # If 'service_account_email' is provided, that service account is used.
  # Otherwise, the default Compute Engine service account is used with the specified scopes.
  service_account {
    email  = var.service_account_email != null ? var.service_account_email : null # Email of the service account.
    scopes = var.service_account_scopes                                           # API access scopes.
  }

  # Startup script to be executed when the instance starts.
  metadata_startup_script = var.metadata_startup_script
}
