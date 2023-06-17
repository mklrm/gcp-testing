#resource "google_project_service" "gke" {
#  count                      = length(local.container_clusters) >= 0 ? 1 : 0
#  project                    = var.default_project # TODO Enable in each local.container_clusters[*].project
#  service                    = "container.googleapis.com"
#  disable_dependent_services = true
#}

resource "google_container_cluster" "main" {
  for_each = { for cluster in local.container_clusters : cluster.name => cluster }
  #depends_on = [
  #  google_project_service.gke
  #]
  name                     = each.value.name
  project                  = each.value.project
  location                 = each.value.location
  remove_default_node_pool = each.value.remove_default_node_pool
  initial_node_count       = each.value.initial_node_count
}

resource "google_service_account" "container_node_pool" {
  for_each     = { for sa in local.container_node_pool_service_accounts : sa.pool_name => sa }
  project      = each.value.project
  account_id   = each.value.account_id
  display_name = each.value.display_name
}

resource "google_container_node_pool" "main" {
  for_each   = { for pool in local.container_node_pools : pool.name => pool }
  name       = each.value.name
  project    = each.value.project
  location   = each.value.location
  cluster    = each.value.cluster
  node_count = each.value.node_count

  node_config {
    preemptible     = each.value.node_config.preemptible
    machine_type    = each.value.node_config.machine_type
    service_account = each.value.node_config.service_account
    oauth_scopes    = each.value.node_config.oauth_scopes
  }
}
