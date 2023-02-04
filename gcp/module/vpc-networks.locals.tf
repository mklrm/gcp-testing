#_name TODO See if it would be possible to get rid of some of these flattenings
locals {
  compute_networks_0 = [
    for network in var.compute_networks : {
      project                 = network.project
      auto_create_subnetworks = network.auto_create_subnetworks
      name = coalesce(
        # If network name was explicitly provided, use as is
        network.name,
        # If network name postfix disable was set to true, use network name prefix as is
        network.name_postfix_disable != null ? network.name_postfix_disable == true ? network.name_prefix : null : null,
        # Try returning "network name-network name postfix", return null if 
        # one or the other wasn't provided
        # TODO Use try(network.name_postfix, "network") to generage the postfix and 
        # get rid of the second try
        # - Or not, because this is terraform and it doesn't work, maybe try again
        #   at some point...
        try(
          "${network.name_prefix}-${network.name_postfix}",
          null
        ),
        # Finally attempt to return "network name-default postfix"
        try(
          "${network.name_prefix}-${var.compute_network_default_postfix}",
          null
        )
      )
      compute_network_peerings = coalesce(network.compute_network_peerings, [])
      compute_subnetworks      = coalesce(network.compute_subnetworks, [])
    }
  ]
  compute_networks_1 = [
    for network in local.compute_networks_0 : {
      name                    = network.name
      project                 = network.project
      auto_create_subnetworks = network.auto_create_subnetworks
      compute_subnetworks = network.compute_subnetworks == null ? [] : [
        for idx, subnetwork in network.compute_subnetworks : {
          project       = network.project
          ip_cidr_range = subnetwork.ip_cidr_range
          region        = subnetwork.region
          name = coalesce(
            subnetwork.name,
            subnetwork.name_prefix_disable != null
            ? subnetwork.name_prefix_disable == true
            ? try("${network.name}-${idx}", null)
            : try("${network.name}-${subnetwork.name_prefix}-${idx}", null)
            : try("${network.name}-${subnetwork.name_prefix}-${idx}", null),
            try("${network.name}-${var.compute_subnetwork_default_prefix}-${idx}", null)
          )
          secondary_ip_ranges = subnetwork.secondary_ip_ranges
        }
      ]
      compute_network_peerings = network.compute_network_peerings == null ? [] : [
        for idx, peering in network.compute_network_peerings : {
          export_custom_routes                = peering.export_custom_routes
          import_custom_routes                = peering.import_custom_routes
          export_subnet_routes_with_public_ip = peering.export_subnet_routes_with_public_ip
          import_subnet_routes_with_public_ip = peering.import_subnet_routes_with_public_ip
          name                                = peering.name
          name_prefix_disable                 = peering.name_prefix_disable
          name_postfix_disable                = peering.name_postfix_disable
          name_idx_enable                     = peering.name_idx_enable
          # TODO It would simplify lots of things if I was able to get around 
          # having to check if a variable is null before checking what the 
          # value is like I do here:
          name_prefix = (
            peering.name_prefix_disable != null
            ? peering.name_prefix_disable == true
            ? ""
            : coalesce(
              try("${peering.name_prefix}", null),
              try("${network.name}-to-${
                coalesce(
                  peering.peer_network_name,
                  peering.peer_network_name_postfix_disable != null ? peering.peer_network_name_postfix_disable == true ? peering.peer_network_name_prefix : null : null,
                  # TODO Merge these two tries by inlining one in the other:
                  try(
                    "${peering.peer_network_name_prefix}-${peering.peer_network_name_postfix}",
                    null
                  ),
                  try(
                    "${peering.peer_network_name_prefix}-${var.compute_network_default_postfix}",
                    null
                  )
                )
              }", null),
            )
            : coalesce(
              try("${peering.name_prefix}", null),
              try("${network.name}-to-${
                coalesce(
                  peering.peer_network_name,
                  peering.peer_network_name_postfix_disable != null ? peering.peer_network_name_postfix_disable == true ? peering.peer_network_name_prefix : null : null,
                  # TODO Merge these two tries by inlining one in the other:
                  try(
                    "${peering.peer_network_name_prefix}-${peering.peer_network_name_postfix}",
                    null
                  ),
                  try(
                    "${peering.peer_network_name_prefix}-${var.compute_network_default_postfix}",
                    null
                  )
                )
              }", null),
            )
          )
          name_postfix = "${
            peering.name_postfix_disable != null
            ? peering.name_postfix_disable == false
            ? peering.name_postfix != null
            ? "-${peering.name_postfix}"
            : "-${var.compute_network_peering_default_postfix}"
            # peering.name_postfix_disable == true:
            : ""
            # peering.name_postfix_disable == null:
            : peering.name_postfix != null
            ? "-${peering.name_postfix}"
            : "${var.compute_network_peering_default_postfix}"
            }${
            peering.name_idx_enable != null
            ? peering.name_idx_enable == true
            ? "-${idx}"
            : ""
            # peering.name_idx_enable == false:
            : ""
          }"
          peer_network_name = coalesce(
            peering.peer_network_name,
            peering.peer_network_name_postfix_disable != null ? peering.peer_network_name_postfix_disable == true ? peering.peer_network_name_prefix : null : null,
            # TODO Merge these two tries by inlining one in the other:
            try(
              "${peering.peer_network_name_prefix}-${peering.peer_network_name_postfix}",
              null
            ),
            try(
              "${peering.peer_network_name_prefix}-${var.compute_network_default_postfix}",
              null
            )
          )
        }
      ]
    }
  ]
  compute_networks = [
    for network in local.compute_networks_1 : {
      name                    = network.name
      project                 = network.project
      auto_create_subnetworks = network.auto_create_subnetworks
      compute_subnetworks = network.compute_subnetworks == null ? [] : [
        for idx, subnetwork in network.compute_subnetworks : {
          name          = subnetwork.name
          project       = network.project
          ip_cidr_range = subnetwork.ip_cidr_range
          region        = subnetwork.region
          compute_subnetwork_secondary_ranges = subnetwork.secondary_ip_ranges == null ? [] : [
            for idx, secondary_range in subnetwork.secondary_ip_ranges : {
              name = coalesce(
                secondary_range.range_name,
                secondary_range.range_name_prefix_disable != null
                ? secondary_range.range_name_prefix_disable == true
                ? try("${subnetwork.name}-${idx}", null)
                : try("${subnetwork.name}-${secondary_range.range_name_prefix}-${idx}", null)
                : try("${subnetwork.name}-${secondary_range.range_name_prefix}-${idx}", null),
                try("${subnetwork.name}-${var.compute_subnetwork_secondary_range_default_postfix}-${idx}", null)
              )
              ip_cidr_range = secondary_range.ip_cidr_range
            }
          ]
        }
      ]
      compute_network_peerings = network.compute_network_peerings == null ? [] : [
        for idx, peering in network.compute_network_peerings : {
          export_custom_routes                = peering.export_custom_routes
          import_custom_routes                = peering.import_custom_routes
          export_subnet_routes_with_public_ip = peering.export_subnet_routes_with_public_ip
          import_subnet_routes_with_public_ip = peering.import_subnet_routes_with_public_ip
          name = coalesce(
            peering.name,
            # If prefix and postfix are disabled and idx_enable isn't set, return idx:
            peering.name_prefix_disable != null
            ? peering.name_prefix_disable == true
            ? peering.name_postfix_disable != null
            ? peering.name_postfix_disable == true
            ? peering.name_idx_enable == null
            ? "${idx}"
            : null
            : null
            : null
            : null
            : null,
            "${peering.name_prefix}${peering.name_postfix}"
          )
          peer_network_name = peering.peer_network_name
        }
      ]
    }
  ]
  compute_subnetworks = flatten([
    for network in local.compute_networks : [
      for subnetwork in network.compute_subnetworks : {
        network_name        = network.name
        name                = subnetwork.name
        project             = network.project
        ip_cidr_range       = subnetwork.ip_cidr_range
        region              = subnetwork.region
        secondary_ip_ranges = coalesce(subnetwork.compute_subnetwork_secondary_ranges, [])
      }
    ]
  ])
  compute_network_peerings = flatten([
    for network in local.compute_networks : [
      for peering in network.compute_network_peerings : {
        name                                = peering.name
        network_name                        = network.name
        peer_network_name                   = peering.peer_network_name
        export_custom_routes                = peering.export_custom_routes
        import_custom_routes                = peering.import_custom_routes
        export_subnet_routes_with_public_ip = peering.export_subnet_routes_with_public_ip
        import_subnet_routes_with_public_ip = peering.import_subnet_routes_with_public_ip
      }
    ]
  ])
}
