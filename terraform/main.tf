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

  project         = var.project # TODO Phase out and remove
  default_project = var.project

  compute_networks = [
    {
      name_prefix             = "amazing-app-spoke"
      project                 = var.project
      auto_create_subnetworks = false
      add_iap_firewall_rule   = true
      compute_network_peerings = [
        {
          name_postfix                      = "pairing"
          peer_network_name_prefix          = "amazing-app-hub"
          peer_network_name_postfix         = "vpc"
          peer_network_name_postfix_disable = true
          name_idx_enable                   = true
        }
      ]
      compute_subnetworks = [
        {
          name_prefix   = "snet"
          ip_cidr_range = "10.2.0.0/16"
          region        = "us-central1"
          secondary_ip_ranges = [
            {
              range_name_prefix = "x"
              ip_cidr_range     = "192.168.10.0/24"
            },
            {
              ip_cidr_range = "192.168.11.0/24"
            }
          ]
        },
        {
          ip_cidr_range = "10.3.0.0/16"
          region        = "us-central1"
        }
      ]
    },
    {
      name_prefix             = "amazing-app-hub"
      name_postfix            = "vpc"
      name_postfix_disable    = true
      project                 = var.project
      auto_create_subnetworks = false
      add_iap_firewall_rule   = false
    },
  ]

  compute_instances = [
    {
      name_prefix  = "compute-instance"
      description  = "A compute instance"
      machine_type = "e2-micro"
      zone         = "us-central1-a"
      project      = var.project

      boot_disk = {
        initialize_params = {
          image = "ubuntu-os-cloud/ubuntu-2204-lts"
        }
      }


      network_interface = [
        {
          subnetwork = "amazing-app-spoke-network-snet-0"
        }
      ]
    }
  ]
}
