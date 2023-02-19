locals {
  container_clusters = [
    for cluster in var.container_clusters : {
      name                     = cluster.name
      project                  = cluster.project != null ? cluster.project : var.default_project
      location                 = cluster.location != null ? cluster.location : var.default_region
      remove_default_node_pool = cluster.remove_default_node_pool != null ? cluster.remove_default_node_pool : var.default_container_cluster_remove_default_node_pool
      initial_node_count       = cluster.initial_node_count != null ? cluster.initial_node_count : default_container_cluster_default_pool_initial_node_count
      container_node_pools = cluster.container_node_pools == null ? [] : [
        for pool in cluster.container_node_pools : {
          name       = pool.name
          project    = pool.project != null ? pool.project : var.default_project
          location   = pool.node_config.location != null ? cluster.location : var.default_region
          node_count = pool.node_count != null ? pool.node_count : var.default_container_cluster_node_pool_initial_node_count
          node_config = {
            preemptible            = pool.node_config.preemptible
            machine_type           = pool.node_config.machine_type
            service_account        = pool.node_config.service_account
            create_service_account = pool.node_config.create_service_account != null ? pool.node_config.create_service_account : var.default_container_cluster_node_pool_create_service_account
            oauth_scopes           = pool.node_config.oauth_scopes
          }
        }
      ]
    }
  ]

  container_node_pools = flatten([
    for cluster in local.container_clusters : [
      for pool in cluster.container_node_pools : {
        cluster    = cluster.name
        name       = pool.name
        node_count = pool.node_count
        node_config = {
          preemptible  = pool.node_config.preemptible
          machine_type = pool.node_config.machine_type
          service_account = (
            pool.create_service_account == null
            ? pool.node_config.service_account
            : pool.create_service_account == true
            ? "gke-pool-${pool.name}-sa@${pool.project}.iam.gserviceaccount.com"
            : null
          )
          create_service_account = pool.node_config.ceate_service_account
          oauth_scopes           = pool.node_config.oauth_scopes
        }
      }
    ]
  ])

  container_node_pool_service_accounts = [
    for pool in locals.container_node_pools : {
      pool_name    = pool.name
      account_id   = "gke-pool-${pool.name}-sa"
      display_name = "Node Pool ${pool.name} Service Account"
    } if pool.create_service_account == true
  ]
}
