locals {
  compute_networks_0 = flatten([
    for network in var.compute_networks : {
      name                     = network.name
      name_explicitly_set      = network.name != null ? true : false
      name_prefix              = network.name_prefix
      name_postfix             = coalesce(network.name_postfix, "network")
      name_postfix_disable     = network.name_postfix_disable != null ? network.name_postfix_disable : false
      project                  = network.project
      auto_create_subnetworks  = network.auto_create_subnetworks
      compute_network_peerings = coalesce(network.compute_network_peerings, [])
      compute_subnetworks      = coalesce(network.compute_subnetworks, [])
    }
  ])
  compute_networks = flatten([
    for network in local.compute_networks_0 : {
      name                     = network.name_explicitly_set == true ? network.name : network.name_postfix_disable == true ? network.name_prefix : "${network.name_prefix}-${network.name_postfix}"
      name_prefix              = network.name_prefix
      name_postfix             = network.name_postfix
      project                  = network.project
      auto_create_subnetworks  = network.auto_create_subnetworks
      compute_network_peerings = network.compute_network_peerings
      compute_subnetworks      = network.compute_subnetworks
    }
  ])
  compute_subnetworks = flatten([
    for network in local.compute_networks : [
      for idx, subnetwork in network.compute_subnetworks : {
        # Use coalesce to use subnet name, subnet name prefix, network name or 
        # network name prefix, in that order of preference, for naming.
        name = coalesce(
          (subnetwork.name != null ? subnetwork.name : null),
          (subnetwork.name_prefix != null ? "${subnetwork.name_prefix}${subnetwork.name_postfix_disable == null ? subnetwork.name_postfix != null ? "-${subnetwork.name_postfix}" : "-subnet" : subnetwork.name_postfix_disable == true ? "" : subnetwork.name_postfix != null ? "-${subnetwork.name_postfix}" : "-subnet"}-${idx}" : null),
          (network.name != null ? "${network.name}${subnetwork.name_postfix_disable == null ? subnetwork.name_postfix != null ? "-${subnetwork.name_postfix}" : "-subnet" : subnetwork.name_postfix_disable == true ? "" : subnetwork.name_postfix != null ? "-${subnetwork.name_postfix}" : "-subnet"}-${idx}" : null),
          (network.name_prefix != null ? "${network.name_prefix}${subnetwork.name_postfix_disable == null ? subnetwork.name_postfix != null ? "-${subnetwork.name_postfix}" : "-subnet" : subnetwork.name_postfix_disable == true ? "" : subnetwork.name_postfix != null ? "-${subnetwork.name_postfix}" : "-subnet"}-${idx}" : null)
        )
        name_prefix         = subnetwork.name_prefix
        project             = network.project
        ip_cidr_range       = subnetwork.ip_cidr_range
        region              = subnetwork.region
        network_name        = network.name
        network_name_prefix = network.name
        secondary_ip_ranges = subnetwork.secondary_ip_ranges != null ? subnetwork.secondary_ip_ranges : []
      }
    ]
  ])
  compute_network_peerings_0 = flatten([
    for network in local.compute_networks : [
      for peering in network.compute_network_peerings : {
        name = coalesce(
          (peering.name != null ? peering.name : null),
          (peering.name_prefix != null ? peering.name_prefix : null),
          (network.name != null ? network.name : null),
          (network.name_prefix != null ? network.name_prefix : null)
        )
        name_explicitly_set  = peering.name != null ? true : false
        name_prefix          = peering.name_prefix
        name_postfix         = coalesce(peering.name_postfix, "peering")
        name_postfix_disable = peering.name_postfix_disable != null ? peering.name_postfix_disable : false
        network_name         = network.name
        peer_network_name = coalesce(
          (peering.peer_network_name != null ? peering.peer_network_name : null),
          (peering.peer_network_name_prefix != null ? peering.peer_network_name_prefix : null),
        )
        peer_network_name_explicitly_set    = peering.peer_network_name != null ? true : false
        peer_network_name_prefix            = peering.peer_network_name_prefix
        peer_network_name_postfix           = coalesce(peering.peer_network_name_postfix, "network")
        peer_network_name_postfix_disable   = peering.peer_network_name_postfix_disable != null ? peering.peer_network_name_postfix_disable : false
        export_custom_routes                = peering.export_custom_routes
        import_custom_routes                = peering.import_custom_routes
        export_subnet_routes_with_public_ip = peering.export_subnet_routes_with_public_ip
        import_subnet_routes_with_public_ip = peering.import_subnet_routes_with_public_ip
      }
    ]
  ])
  compute_network_peerings = flatten([
    for peering in local.compute_network_peerings_0 : {
      name                                = peering.name_explicitly_set == true ? peering.name : "${peering.name}-to-${peering.peer_network_name}${peering.peer_network_name_postfix_disable == true ? "" : "-${peering.peer_network_name_postfix}"}${peering.name_postfix_disable == true ? "" : "-${peering.name_postfix}"}"
      peer_network_name                   = peering.peer_network_name_explicitly_set == true ? peering.peer_network_name : "${peering.peer_network_name}${peering.peer_network_name_postfix_disable == true ? "" : "-${peering.peer_network_name_postfix}"}"
      peer_network_name_postfix_disable   = peering.peer_network_name_postfix_disable
      network_name                        = peering.network_name
      export_custom_routes                = peering.export_custom_routes
      import_custom_routes                = peering.import_custom_routes
      export_subnet_routes_with_public_ip = peering.export_subnet_routes_with_public_ip
      import_subnet_routes_with_public_ip = peering.import_subnet_routes_with_public_ip
    }
  ])
}
