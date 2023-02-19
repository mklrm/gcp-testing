terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.49.0"
    }
  }
  backend "local" {
    path = "state/terraform.tfstate"
  }
}

provider "google" {
  # Configuration options
}

module "dynamic_deployment" {
  source = "./module"

  default_project = var.project

  compute_networks = [
    {
      name_prefix             = "amazing-app-spoke"
      auto_create_subnetworks = false
      add_iap_firewall_rule   = true
      tags                    = ["abc"]

      compute_network_peerings = [
        {
          # TODO Add picking out peer network using a tag
          #peer_network_name_prefix = "amazing-app-hub"
          peer_network_tags = ["abc", "def"]
        }
      ]
      compute_subnetworks = [
        {
          ip_cidr_range        = "10.2.0.0/16"
          instance_attach_tags = ["amazing-app-spoke"]
          secondary_ip_ranges = [
            {
              ip_cidr_range = "192.168.10.0/24"
            },
            {
              ip_cidr_range = "192.168.11.0/24"
            }
          ]
        },
        {
          ip_cidr_range = "10.3.0.0/16"
        }
      ]
      cloud_nats = [
        {
          # Just an empty block will create a Cloud NAT
        },
      ]
    },
    {
      name_prefix             = "amazing-app-hub"
      auto_create_subnetworks = false
      add_iap_firewall_rule   = false
      tags                    = ["def"]

      cloud_nats = [
        {
        },
      ]

      compute_network_peerings = [
        {
          # TODO Add picking out peer network using a tag
          #peer_network_name_prefix = "amazing-app-hub"
          peer_network_tags = ["abc", "def"]
        }
      ]
    },
  ]

  compute_instances = [
    {
      name_prefix  = "compute-instance"
      description  = "A compute instance"
      machine_type = "e2-micro"
      zone         = "us-central1-a"

      boot_disk = {
        initialize_params = {
          image = "ubuntu-os-cloud/ubuntu-2204-lts"
        }
      }

      network_interface = [
        {
        }
      ]

      tags = ["amazing-app-spoke"]
    }
  ]
}
