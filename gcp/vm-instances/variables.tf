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
        labels = optional(map({}))
      }))
      source = optional(string)
    }))
    machine_type = optional(string)
    name         = optional(string)
    name_prefix  = optional(string)
    zone         = optional(string)
    network_interface = optional(object({
      network            = optional(string)
      subnetwork         = optional(string)
      subnetwork_project = optional(string)
      network_ip         = optional(string)
      access_config = optional(object({
        nat_ip                 = optional(string)
        public_ptr_domain_name = optional(string)
        network_tier           = optional(string)
      }))
    }))
  }))
}
