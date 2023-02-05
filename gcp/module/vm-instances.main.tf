data "cloudinit_config" "conf" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = file("module/cloud-init/config.yaml")
    filename     = "config.yaml"
  }
}

resource "google_compute_instance" "compute_instances" {
  for_each     = { for instance in local.compute_instances : instance.name => instance }
  name         = each.value.name
  description  = each.value.description
  machine_type = each.value.machine_type
  project      = each.value.project
  zone         = each.value.zone

  # TODO Try to get this working
  #dynamic "boot_disk" {
  #  for_each = each.value.boot_disk[*]
  #  content {
  #    dynamic "initialize_params" {
  #      for_each = boot_disk.value.initialize_params
  #      content {
  #        image = initialize_params.value.image
  #      }
  #    }
  #  }
  #}

  boot_disk {
    initialize_params {
      image = each.value.boot_disk_initialize_params_image
    }
  }

  dynamic "network_interface" {
    for_each = each.value.network_interface[*]
    content {
      subnetwork = resource.google_compute_subnetwork.compute_subnetworks[network_interface.value.subnetwork].self_link
    }
  }

  metadata = {
    user-data = data.cloudinit_config.conf.rendered
  }

  # TODO Add add_allow_iap_tag boolean
  tags = ["allow-iap"]
}
