# Terraform configuration for deploying a Streamlit application on a Google Compute Engine instance.

# Specifies the Google Cloud provider.
provider "google" {
  project = var.project_id # GCP Project ID
  region  = var.region     # Region for resource deployment
  zone    = var.zone       # Zone for resource deployment
}

# Defines the Google Compute Engine instance using a local module.
# This module encapsulates the instance configuration details.
module "gce_instance" {
  source = "./modules/gce_instance" # Path to the local module

  instance_name   = var.instance_name   # Name of the GCE instance
  machine_type    = var.machine_type    # Machine type for the GCE instance
  boot_disk_image = var.image           # Image for the instance's boot disk
  boot_disk_size  = var.disk_size       # Size of the boot disk in GB
  tags            = ["streamlit-server"] # Network tags to apply to the instance, used by firewall rules.

  # For enhanced security, consider creating a dedicated service account with minimal permissions
  # and providing its email via the 'service_account_email' variable in this module block.
  # e.g., service_account_email = "your-custom-sa@your-project-id.iam.gserviceaccount.com"
  # service_account_email = null # This module input defaults to null, so the GCE default SA will be used.

  # Startup script to install Streamlit and run a sample application.
  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e

    # システムの更新とPython環境のセットアップ
    apt-get update
    apt-get install -y python3-pip

    # Streamlitのインストール
    pip3 install streamlit

    # アプリケーションの作成
    cat <<EOT > /home/app.py
    import streamlit as st

    st.title('GCP Streamlit Minimal')
    st.write('Welcome to the minimal Streamlit application on GCP!')
    
    # サンプル機能
    number = st.slider('Select a number', 0, 100, 50)
    st.write(f'Selected number: {number}')
    EOT

    # Streamlitの起動
    # バックグラウンドで実行し、ログをファイルに出力
    nohup streamlit run /home/app.py \
      --server.port=${var.streamlit_port} \
      --server.address=0.0.0.0 \
      > /var/log/streamlit.log 2>&1 &
  EOF

  service_account_scopes = ["cloud-platform"] # Scopes for the service account (default or custom)
}

# Firewall rule to allow TCP traffic to the Streamlit application port.
resource "google_compute_firewall" "streamlit" {
  name    = "allow-streamlit"     # Name of the firewall rule
  network = "default"             # Network to which the rule applies

  allow {
    protocol = "tcp"
    ports    = [var.streamlit_port] # Allows traffic on the Streamlit port (default 8501)
  }

  # Applies this rule only to instances with the "streamlit-server" tag.
  target_tags = ["streamlit-server"]
  
  # IMPORTANT: Restrict this to your IP address for security.
  # TODO: Replace YOUR_IP_ADDRESS/32 with your actual IP address or a specific range.
  source_ranges = ["YOUR_IP_ADDRESS/32"] # Allows traffic from the specified IP range.
}

# Firewall rule to allow TCP traffic for SSH access.
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"             # Name of the firewall rule
  network = "default"             # Network to which the rule applies (consistent with GCE module)

  allow {
    protocol = "tcp"
    ports    = [var.ssh_port]     # Allows traffic on the SSH port (default 22)
  }

  # Applies this rule only to instances with the "streamlit-server" tag.
  target_tags   = ["streamlit-server"]
  source_ranges = ["0.0.0.0/0"]      # Allows SSH traffic from any IP address.
                                     # Consider restricting this for enhanced security if needed.
}

# Outputs are defined in outputs.tf.
# This comment is to signify the end of resource definitions in this file.
