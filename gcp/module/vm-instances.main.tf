#resource "google_compute_instance" "compute_instances" {
#  for_each     = { for instance in local.compute_instances : instance.name => instance }
#  name         = each.value.name
#  description  = each.value.description
#  machine_type = each.value.machine_type
#  project      = each.value.project
#  zone         = each.value.zone
#
#  #dynamic "boot_disk" {
#  #  for_each = each.value.boot_disk[*]
#  #  content {
#  #    dynamic "initialize_params" {
#  #      for_each = boot_disk.value.initialize_params
#  #      content {
#  #        image = initialize_params.value.image
#  #      }
#  #    }
#  #  }
#  #}
#
#  boot_disk {
#    initialize_params {
#      image = each.value.boot_disk_initialize_params_image
#    }
#  }
#
#  dynamic "network_interface" {
#    for_each = each.value.network_interface[*]
#    content {
#      #network = network_interface.value.network
#      #network = module.compute_networks.google_compute_network.compute_networks["amazing-app-spoke-network"]
#      network = resource.google_compute_network.compute_networks[network_interface.value.network_name].self_link
#    }
#  }
#}
#

