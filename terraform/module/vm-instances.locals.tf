locals {
  compute_instances = [
    for idx, instance in var.compute_instances : {
      name = coalesce(
        instance.name != null ? instance.name : null,
        instance.name_postfix_disable != null ? instance.name_postfix_disable == false ? "${instance.name_prefix}-${idx}-${instance.name_postfix != null ? instance.name_postfix : "vm"}" : "${instance.name_prefix}-${idx}" : "${instance.name_prefix}-${idx}-${instance.name_postfix != null ? instance.name_postfix : "vm"}"
      )
      name_prefix                       = instance.name_prefix
      name_postfix                      = instance.name_postfix
      name_postfix_disable              = instance.name_postfix_disable
      boot_disk_initialize_params_image = instance.boot_disk.initialize_params.image != null ? instance.boot_disk.initialize_params.image : "debian-cloud/debian-11"
      machine_type                      = instance.machine_type
      zone                              = instance.zone
      cloud_config_name                 = instance.cloud_config_name
      network_interface = instance.network_interface == null ? [] : [
        for idx, network_interface in instance.network_interface : {
          subnetwork = network_interface.subnetwork != null ? network_interface.subnetwork : null,
        }
      ]
      allow_stopping_for_update = instance.allow_stopping_for_update
      attached_disk             = instance.attached_disk
      can_ip_forward            = instance.can_ip_forward
      description               = instance.description
      desired_status            = instance.desired_status
      deletion_protection       = instance.deletion_protection
      hostname                  = instance.hostname
      guest_accelerator         = instance.guest_accelerator
      labels                    = instance.labels
      metadata                  = instance.metadata
      metadata_startup_script   = instance.metadata_startup_script
      min_cpu_platform          = instance.min_cpu_platform
      project                   = instance.project != null ? instance.project : var.default_project
      scheduling                = instance.scheduling
      scratch_disk              = instance.scratch_disk
      service_account           = instance.service_account
      tags                      = instance.tags
      tags = concat(
        instance.tags,
        instance.add_allow_iap_tag != null
        ? instance.add_allow_iap_tag == true
        ? ["allow-iap"]
        : []
        : ["allow-iap"]
      )
      shielded_instance_config     = instance.shielded_instance_config
      enable_display               = instance.enable_display
      resource_policies            = instance.resource_policies
      reservation_affinity         = instance.reservation_affinity
      confidential_instance_config = instance.confidential_instance_config
      advanced_machine_features    = instance.advanced_machine_features
      network_performance_config   = instance.network_performance_config
    }
  ]
  cloud_init_configs = [
    {
      gzip          = false
      base64_encode = false
      name          = "basic"
    },
    {
      gzip          = false
      base64_encode = false
      name          = "k8s"
    }
  ]
}

