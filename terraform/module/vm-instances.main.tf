
data "cloudinit_config" "main" {
  for_each      = { for cloud_init_config in local.cloud_init_configs : cloud_init_config.name => cloud_init_config }
  gzip          = each.value.gzip != null ? each.value.gzip == true ? true : false : false
  base64_encode = each.value.base64_encode != null ? each.value.base64_encode == true ? true : false : false

  part {
    content_type = "text/cloud-config"
    content      = file("module/cloud-init/${each.value.name != null ? each.value.name : "basic"}.yaml")
    filename     = "${each.value.name != null ? each.value.name : "basic"}.yaml"
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
      # If subnetwork was not explicitly provided, use network tags to 
      # try and find a subnetwork to connect to
      subnetwork = network_interface.value.subnetwork != null ? network_interface.value.subnetwork : resource.google_compute_subnetwork.compute_subnetworks[flatten(flatten([
        # NOTE One would hope there's a better way of doing this
        for tag in each.value.tags : {
          subnetwork = [
            for subnet in local.compute_subnetworks : {
              subnet = contains(subnet.instance_attach_tags, tag) ? subnet.name : null
            }
          ]
        }
      ][*]["subnetwork"][*]["subnet"][*]))[0]].self_link
    }
  }

  metadata = {
    #user-data = data.cloudinit_config.conf.rendered
    user-data = data.cloudinit_config.main[each.value.cloud_config_name != null ? each.value.cloud_config_name : "basic"].rendered
  }

  tags = each.value.tags
}
