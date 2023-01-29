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
  compute_networks = [
    {
      #name                    = "booyah"
      name_prefix = "amazing-app-spoke"
      #name_postfix = "vpc"
      #name_postfix_disable    = true
      project                 = var.project
      auto_create_subnetworks = false
      compute_network_peerings = [
        {
          # works:
          #name = "explicit-name"
          # works:
          #name_prefix = "boom"
          # works:
          #name_postfix = "vpc" # Default is "peering"
          # works:
          #name_postfix_disable     = true
          # works:
          peer_network_name_prefix = "amazing-app-hub"
          # works:
          peer_network_name_postfix = "vpc" # default is "network"
          # works:
          peer_network_name_postfix_disable = true
        }
      ]
      compute_subnetworks = [
        {
          # works:
          #name_postfix = "snet"
          # works:
          #name_postfix_disable = true
          ip_cidr_range = "10.2.0.0/16"
          region        = "us-central1"
          secondary_ip_ranges = [
            {
              # works:
              #range_name    = "x"
              ip_cidr_range = "192.168.10.0/24"
            },
            {
              #range_name    = "y"
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
      #compute_subnetworks = [
      #  {
      #    ip_cidr_range = "10.4.0.0/16"
      #    region        = "us-central1"
      #  }
      #]
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
          image = "debian-cloud/debian-11"
        }
      }

      network_interface = [
        {
          network_name_prefix = "amazing-app-spoke"
        }
      ]
    }
  ]
}
