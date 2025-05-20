<div align="center">

# ☁️ GCP Streamlit Minimal with Terraform

</div>

This project provides Terraform configuration to deploy a minimal Streamlit application on a Google Compute Engine (GCE) instance. It's designed to be a simple, secure, and modular starting point.

## 📋 Overview

-   🖥️ **Compute Instance:** Deploys a `e2-micro` GCE instance by default.
-   🐧 **Operating System:** Uses a Debian 11 base image.
-    streamlit **Application:** Sets up a basic Streamlit application that displays a title and a slider.
-   🌐 **Networking:**
    -   Exposes the Streamlit application on port 8501 (configurable).
    -   Sets up firewall rules to allow access to Streamlit and SSH.
    -   **Security Note:** The Streamlit firewall rule is initially restricted to a placeholder IP. You **must** update this to your IP address.
-   🧱 **Modularity:** Uses a local Terraform module for the GCE instance configuration.

## 📂 Project Structure

```
.
├── main.tf                 # Root configuration: provider, module call, firewall rules
├── variables.tf            # Root variables: project_id, region, instance settings, etc.
├── outputs.tf              # Root outputs: streamlit_url, instance_ip
├── README.md               # This file
└── modules/
    └── gce_instance/
        ├── main.tf         # Module: GCE instance resource definition
        ├── variables.tf    # Module: Input variables for the GCE instance
        └── outputs.tf      # Module: Outputs from the GCE instance (ID, name, network details)
```

## 🛠️ Prerequisites

1.  **Google Cloud Platform (GCP) Account:** You'll need a GCP account with an active project.
2.  **Billing Enabled:** Ensure billing is enabled for your GCP project.
3.  **APIs Enabled:** The following APIs must be enabled in your GCP project:
    *   Compute Engine API
    *   Cloud Resource Manager API (usually enabled by default)
    You can enable them via the GCP Console or `gcloud services enable compute.googleapis.com cloudresourcemanager.googleapis.com`.
4.  **Terraform Installed:** Download and install Terraform from [terraform.io](https://www.terraform.io/downloads.html).
5.  **Google Cloud SDK (`gcloud`) Configured:** Install and configure the `gcloud` CLI. Authenticate with GCP by running:
    ```bash
    gcloud auth application-default login
    ```
    This allows Terraform to authenticate to your GCP account.

## ⚙️ Configuration

1.  **Clone the Repository (if applicable):**
    ```bash
    # git clone <repository_url>
    # cd <repository_directory>
    ```

2.  **Project ID:**
    Open `variables.tf` and update the `project_id` default value:
    ```terraform
    variable "project_id" {
      description = "The ID of the GCP project."
      type        = string
      default     = "your-project-id" # <-- CHANGE THIS
    }
    ```
    Alternatively, you can create a `terraform.tfvars` file (which is gitignored by default if you add `*.tfvars` to `.gitignore`) and set your project ID there:
    ```terraform
    # terraform.tfvars
    project_id = "your-actual-project-id"
    ```
    Or, provide it at apply time (not recommended for sensitive values):
    ```bash
    terraform apply -var="project_id=your-actual-project-id"
    ```

3.  **Critical Security: Update Firewall Rule for Streamlit:**
    Open `main.tf`. Locate the `google_compute_firewall` resource named `allow-streamlit`. You **must** change the `source_ranges` from the placeholder to your IP address/range to ensure only you can access your Streamlit application.
    ```terraform
    resource "google_compute_firewall" "streamlit" {
      # ... other configuration ...
      
      # IMPORTANT: Restrict this to your IP address for security.
      # TODO: Replace YOUR_IP_ADDRESS/32 with your actual IP address or a specific range.
      source_ranges = ["YOUR_IP_ADDRESS/32"] # <-- CHANGE THIS (e.g., ["1.2.3.4/32"])
    }
    ```
    To find your public IP address, you can search "what is my IP" in Google.

4.  **Other Variables:**
    Review `variables.tf` for other settings you might want to customize, such as:
    *   `region`, `zone`
    *   `instance_name`, `machine_type`
    *   `image`, `disk_size`
    *   `streamlit_port`, `ssh_port`

5.  **Custom Service Account (Optional, Recommended for Enhanced Security):**
    The GCE instance module is prepared to use a custom service account.
    *   Create a dedicated service account in GCP with the minimal necessary permissions.
    *   In `main.tf`, uncomment and set the `service_account_email` parameter within the `module "gce_instance"` block:
        ```terraform
        module "gce_instance" {
          source = "./modules/gce_instance"
          # ... other parameters ...
          # For enhanced security, create a dedicated service account with minimal permissions
          # and provide its email via the 'service_account_email' variable in this module block.
          # e.g., service_account_email = "your-custom-sa@your-project-id.iam.gserviceaccount.com"
          # service_account_email = "your-custom-sa@your-project-id.iam.gserviceaccount.com"
        }
        ```
    If `service_account_email` is not provided or set to `null`, the instance will use the default Compute Engine service account with `cloud-platform` scopes.

## 🚀 Deployment

1.  **Initialize Terraform:**
    Navigate to the root directory of the project in your terminal and run:
    ```bash
    terraform init
    ```
    This command initializes the working directory, downloading the necessary provider plugins.

2.  **Plan the Deployment:**
    (Optional but recommended) See what resources Terraform will create/modify:
    ```bash
    terraform plan
    ```

3.  **Apply the Configuration:**
    Deploy the resources:
    ```bash
    terraform apply
    ```
    Type `yes` when prompted to confirm the deployment.

## 🌐 Accessing the Application

Once `terraform apply` is complete, Terraform will output the URL for your Streamlit application:

1.  **Get the Streamlit URL:**
    ```bash
    terraform output streamlit_url
    ```
    It will look something like: `http://<EXTERNAL_IP_ADDRESS>:8501`

2.  **Open in Browser:**
    Copy and paste this URL into your web browser. Remember that access is restricted by the firewall rule you configured.

## 💻 SSH Access

You can SSH into the Compute Engine instance for maintenance or debugging.

1.  **Get Instance Details:**
    You can get the instance's external IP from the Terraform outputs:
    ```bash
    terraform output instance_ip
    ```
    You will also need the instance name and zone, which are defined in `variables.tf` (or your `.tfvars` file).

2.  **Connect using `gcloud` (Recommended):**
    The easiest way to SSH is using the `gcloud` command-line tool, which handles SSH key management automatically:
    ```bash
    gcloud compute ssh <YOUR_INSTANCE_NAME> --project <YOUR_PROJECT_ID> --zone <YOUR_INSTANCE_ZONE>
    ```
    Replace `<YOUR_INSTANCE_NAME>`, `<YOUR_PROJECT_ID>`, and `<YOUR_INSTANCE_ZONE>` with your actual values. For example:
    ```bash
    gcloud compute ssh streamlit --project your-project-id --zone asia-northeast1-a
    ```

3.  **Connect using a standard SSH client:**
    If you prefer, you can use a standard SSH client. You'll need to ensure your SSH public key is added to the instance (gcloud does this automatically, or you can manage SSH keys via instance metadata).
    ```bash
    ssh -i /path/to/your/private_key your_gcp_user@<INSTANCE_EXTERNAL_IP>
    ```
    Replace `/path/to/your/private_key` with the path to your SSH private key, `your_gcp_user` with your Linux username on the instance (often your Google account username without the `@domain.com`), and `<INSTANCE_EXTERNAL_IP>` with the IP address.

## 🧹 Cleaning Up

To remove all resources created by this Terraform configuration:

1.  **Destroy Resources:**
    ```bash
    terraform destroy
    ```
    Type `yes` when prompted to confirm the deletion.

## 🧱 Modules

### `gce_instance`

This local module (`./modules/gce_instance`) is responsible for creating and configuring the Google Compute Engine instance. It takes various inputs (like instance name, machine type, image, startup script) and outputs details about the created instance. This modular approach helps in organizing the code and makes the GCE instance configuration reusable if needed.

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file (if one exists) or assume MIT if not present.
```
