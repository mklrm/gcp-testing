resource "google_compute_network" "compute_networks" {
  for_each                = { for network in local.compute_networks : network.name => network }
  name                    = each.value.name
  project                 = each.value.project
  auto_create_subnetworks = each.value.auto_create_subnetworks
}

resource "google_compute_subnetwork" "compute_subnetworks" {
  for_each      = { for subnetwork in local.compute_subnetworks : subnetwork.name => subnetwork }
  name          = each.value.name
  project       = each.value.project
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.compute_networks[each.value.network_name].id
  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges[*]
    content {
      range_name = coalesce(
        (try(secondary_ip_ranges.value.range_name, null) != null ? secondary_ip_ranges.value.range_name : null),
        (each.value.name != null ? "${each.value.name}-secondary-range-${secondary_ip_ranges.key}" : null)
      )
      ip_cidr_range = secondary_ip_ranges.value.ip_cidr_range
    }
  }
}

resource "google_compute_network_peering" "compute_network_peerings" {
  for_each                            = { for peering in local.compute_network_peerings : (peering.name_explicitly_defined == true ? peering.name : "${peering.name}-peering-to-${peering.peer_network_name}") => peering }
  name                                = each.value.name_explicitly_defined == true ? each.value.name : "${each.value.name}-peering-to-${each.value.peer_network_name}"
  network                             = google_compute_network.compute_networks[each.value.name].self_link
  peer_network                        = google_compute_network.compute_networks[each.value.peer_network_name].self_link
  export_custom_routes                = each.value.export_custom_routes
  import_custom_routes                = each.value.import_custom_routes
  export_subnet_routes_with_public_ip = each.value.export_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = each.value.import_subnet_routes_with_public_ip
}