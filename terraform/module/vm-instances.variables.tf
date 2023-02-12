variable "compute_instances" {
  default     = []
  description = "Virtual machines"
  type = list(object({
    boot_disk = optional(object({
      auto_delete             = optional(bool)
      device_name             = optional(string)
      mode                    = optional(string)
      disk_encryption_key_raw = optional(string)
      kms_key_self_link       = optional(string)
      initialize_params = optional(object({
        size   = optional(number)
        type   = optional(string)
        image  = optional(string)
        labels = optional(map(string))
      }))
      source = optional(string)
    }))
    machine_type         = optional(string)
    name                 = optional(string)
    name_prefix          = optional(string)
    name_postfix         = optional(string)
    name_postfix_disable = optional(bool)
    zone                 = optional(string)
    network_interface = optional(list(object({
      network_name                    = optional(string)
      network_name_prefix             = optional(string)
      network_name_postfix            = optional(string)
      network_name_postfix_disable    = optional(string)
      subnetwork_name                 = optional(string)
      subnetwork_name_prefix          = optional(string)
      subnetwork_name_postfix         = optional(string)
      subnetwork_name_postfix_disable = optional(string)
      network                         = optional(string)
      subnetwork                      = optional(string)
      subnetwork_project              = optional(string)
      network_ip                      = optional(string)
      access_config = optional(object({
        nat_ip                 = optional(string)
        public_ptr_domain_name = optional(string)
        network_tier           = optional(string)
      }))
    })))
    allow_stopping_for_update = optional(bool)
    attached_disk = optional(list(object({
      source                  = string
      device_name             = optional(string)
      mode                    = optional(string)
      disk_encryption_key_raw = optional(string)
      kms_key_self_link       = optional(string)
    })))
    can_ip_forward      = optional(bool)
    description         = optional(string)
    desired_status      = optional(string)
    deletion_protection = optional(bool)
    hostname            = optional(string)
    guest_accelerator = optional(object({
      type  = optional(string)
      count = optional(number)
    }))
    labels                  = optional(map(string))
    metadata                = optional(map(string))
    metadata_startup_script = optional(string)
    min_cpu_platform        = optional(string)
    project                 = optional(string)
    scheduling = optional(object({
      preemptible         = optional(bool)
      on_host_maintenance = optional(string)
      automatic_restart   = optional(bool)
      node_affinities = optional(object({
        key      = string
        operator = string
        values   = string
      }))
      min_node_cpus               = optional(number)
      provisioning_model          = optional(string)
      instance_termination_action = optional(string)
      max_run_duration = optional(object({
        nanos   = optional(number)
        seconds = optional(number)
      }))
    }))
    scratch_disk = optional(object({
      interface = optional(string)
    }))
    service_account = optional(object({
      email  = optional(string)
      scopes = optional(list(string))
    }))
    tags              = optional(list(string))
    add_allow_iap_tag = optional(bool)
    shielded_instance_config = optional(object({
      enable_secure_boot          = optional(bool)
      enable_vtpm                 = optional(bool)
      enable_integrity_monitoring = optional(bool)
    }))
    enable_display    = optional(bool)
    resource_policies = optional(list(string))
    reservation_affinity = optional(object({
      type = string
      specific_reservation = optional(object({
        key    = string
        values = string
      }))
    }))
    confidential_instance_config = optional(object({
      enable_confidential_compute = optional(bool)
    }))
    advanced_machine_features = optional(object({
      enable_nested_virtualization = optional(bool)
      thread_per_core              = optional(number)
      visible_core_count           = optional(number)
    }))
    network_performance_config = optional(object({
      total_egress_bandwidth_tier = optional(string)
    }))
  }))
}
