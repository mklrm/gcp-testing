resource "google_container_cluster" "main" {
  for_each                 = { for cluster in local.container_cluster : cluster.name => cluster }
  name                     = each.value.name
  location                 = each.value.location
  remove_default_node_pool = each.value.remove_default_node_pool
  initial_node_count       = each.value.initial_node_count
}

resource "google_service_account" "container_node_pool" {
  for_each     = { for sa in local.container_node_pool_service_accounts : sa.pool_name => sa }
  account_id   = pool.account_id
  display_name = pool.display_name
}

resource "google_container_node_pool" "main" {
  for_each   = { for pool in local.container_node_pools : pool.name => pool }
  name       = each.value.name
  location   = each.value.name
  cluster    = each.value.cluster_name
  node_count = each.value.node_count

  node_config {
    preemptible     = pool.node_config.preemptible
    machine_type    = pool.node_config.machine_type
    service_account = pool.node_config.service_account
    oauth_scopes    = pool.node_config_oauth_scopes
  }
}
