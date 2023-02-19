variable "default_container_cluster_remove_default_node_pool" {
  default     = true
  description = "Remove default node pool"
  type        = bool
}

variable "default_container_cluster_default_pool_initial_node_count" {
  default     = 1
  description = "Default node pool initial node count"
  type        = number
}

variable "default_container_cluster_node_pool_initial_node_count" {
  default     = 1
  description = "Node pool initial node count"
  type        = number
}

variable "default_container_cluster_node_pool_create_service_account" {
  default     = true
  description = "Create service account if service_account is set"
  type        = bool
}

variable "container_clusters" {
  default     = []
  description = "Google Kubernetes Engine clusters"
  type = list(object({
    name                     = string
    project                  = optional(string)
    location                 = optional(string)
    remove_default_node_pool = optional(bool)
    initial_node_count       = optional(number)
    container_node_pools = optional(list(object({
      name       = string
      project    = optional(string)
      location   = optional(string)
      node_count = optional(number)
      node_config = optional(object({
        preemptible            = optional(bool)
        machine_type           = optional(bool)
        service_account        = optional(string)
        create_service_account = optional(bool)
        oauth_scopes           = optional(list(string))
      }))
    })))
  }))
}
