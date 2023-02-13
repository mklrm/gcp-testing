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
          name_postfix     = "snet"
          name_idx_disable = true
          ip_cidr_range    = "10.2.0.0/16"
          #region        = "us-central1"
          instance_attach_tags = ["amazing-app-spoke"]
          secondary_ip_ranges = [
            {
              range_name_postfix     = "x"
              range_name_idx_disable = true
              ip_cidr_range          = "192.168.10.0/24"
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
      cloud_nats = [
        {
          # works:
          #name = "cloud-nat-1"
          # works:
          name_postfix = "carrot"
          # works:
          #name_postfix_disable = true
          # works:
          name_idx_disable = true
        },
        #{
        #  name = "cloud-nat-2"
        #  #router = "asdasadasd"
        #},
      ]
    },
    {
      name_prefix             = "amazing-app-hub"
      name_postfix            = "vpc"
      name_postfix_disable    = true
      project                 = var.project
      auto_create_subnetworks = false
      add_iap_firewall_rule   = false
      cloud_nats = [
        {
          name = "cloud-nat-3"
          #router = "asdaasdads"
        },
        #{
        #  name = "cloud-nat-4"
        #  #router = "asdasadasd"
        #},
      ]
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
          #subnetwork = "amazing-app-spoke-network-snet-1"
        }
      ]

      tags = ["amazing-app-spoke"]
    }
  ]
}
