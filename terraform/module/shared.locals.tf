#locals {
#  compute_network_names_0 = [
#    for network in var.compute_networks : {
#      name = coalesce(
#        # If network name was explicitly provided, use as is
#        network.name,
#        # If network name postfix disable was set to true, use network name prefix as is
#        network.name_postfix_disable != null ? network.name_postfix_disable == true ? network.name_prefix : null : null,
#        # Try returning "network name-network name postfix", return null if 
#        # one or the other wasn't provided
#        try(
#          "${network.name_prefix}-${network.name_postfix}",
#          null
#        ),
#        # Finally attempt to return "network name-default postfix"
#        try(
#          "${network.name_prefix}-network",
#          null
#        )
#      )
#      compute_subnetworks      = network.compute_subnetworks == null ? [] : network.compute_subnetworks
#      compute_network_peerings = network.compute_network_peerings == null ? [] : network.compute_network_peerings
#    }
#  ]
#  compute_network_names_1 = [
#    for network in local.compute_network_names_0 : {
#      name = network.name
#      compute_subnetwork_names = network.compute_subnetworks == null ? [] : [
#        for idx, subnetwork in network.compute_subnetworks : {
#          name = coalesce(
#            subnetwork.name,
#            subnetwork.name_prefix_disable != null
#            ? subnetwork.name_prefix_disable == true
#            ? try("${network.name}-${idx}", null)
#            : try("${network.name}-${subnetwork.name_prefix}-${idx}", null)
#            : try("${network.name}-${subnetwork.name_prefix}-${idx}", null),
#            try("${network.name}-subnet-${idx}", null)
#          )
#          secondary_ip_ranges = subnetwork.secondary_ip_ranges
#        }
#      ]
#      compute_network_peering_names = network.compute_network_peerings == null ? [] : [
#        for idx, peering in network.compute_network_peerings : {
#          name                 = peering.name
#          name_prefix_disable  = peering.name_prefix_disable
#          name_postfix_disable = peering.name_postfix_disable
#          name_idx_enable      = peering.name_idx_enable
#          # TODO It would simplify lots of things if I was able to get around 
#          # having to check if a variable is null before checking what the 
#          # value is like I do here:
#          name_prefix = (
#            peering.name_prefix_disable != null
#            ? peering.name_prefix_disable == true
#            ? ""
#            : coalesce(
#              try("${peering.name_prefix}", null),
#              try("${network.name}-to-${
#                coalesce(
#                  peering.peer_network_name,
#                  peering.peer_network_name_postfix_disable != null ? peering.peer_network_name_postfix_disable == true ? peering.peer_network_name_prefix : null : null,
#                  try(
#                    "${peering.peer_network_name_prefix}-${peering.peer_network_name_postfix}",
#                    null
#                  ),
#                  try(
#                    "${peering.peer_network_name_prefix}-network",
#                    null
#                  )
#                )
#              }", null),
#            )
#            : coalesce(
#              try("${peering.name_prefix}", null),
#              try("${network.name}-to-${
#                coalesce(
#                  peering.peer_network_name,
#                  peering.peer_network_name_postfix_disable != null ? peering.peer_network_name_postfix_disable == true ? peering.peer_network_name_prefix : null : null,
#                  try(
#                    "${peering.peer_network_name_prefix}-${peering.peer_network_name_postfix}",
#                    null
#                  ),
#                  try(
#                    "${peering.peer_network_name_prefix}-network",
#                    null
#                  )
#                )
#              }", null),
#            )
#          )
#          name_postfix = "${
#            peering.name_postfix_disable != null
#            ? peering.name_postfix_disable == false
#            ? peering.name_postfix != null
#            ? "-${peering.name_postfix}"
#            : "-peering"
#            # peering.name_postfix_disable == true:
#            : ""
#            # peering.name_postfix_disable == null:
#            : peering.name_postfix != null
#            ? "-${peering.name_postfix}"
#            : "-peering"
#            }${
#            peering.name_idx_enable != null
#            ? peering.name_idx_enable == true
#            ? "-${idx}"
#            : ""
#            # peering.name_idx_enable == false:
#            : ""
#          }"
#        }
#      ]
#    }
#  ]
#  compute_network_names = [
#    for network in local.compute_network_names_1 : {
#      name = network.name
#      compute_subnetwork_names = network.compute_subnetwork_names == null ? [] : [
#        for idx, subnetwork in network.compute_subnetwork_names : {
#          name = subnetwork.name
#          compute_subnetwork_secondary_range_names = subnetwork.secondary_ip_ranges == null ? [] : [
#            for idx, secondary_range in subnetwork.secondary_ip_ranges : {
#              name = coalesce(
#                secondary_range.range_name,
#                secondary_range.range_name_prefix_disable != null
#                ? secondary_range.range_name_prefix_disable == true
#                ? try("${subnetwork.name}-${idx}", null)
#                : try("${subnetwork.name}-${secondary_range.range_name_prefix}-${idx}", null)
#                : try("${subnetwork.name}-${secondary_range.range_name_prefix}-${idx}", null),
#                try("${subnetwork.name}-secondary-range-${idx}", null)
#              )
#            }
#          ]
#        }
#      ]
#      compute_network_peering_names = network.compute_network_peering_names == null ? [] : [
#        for idx, peering in network.compute_network_peering_names : {
#          name = coalesce(
#            peering.name,
#            # If prefix and postfix are disabled and idx_enable isn't set, return idx:
#            peering.name_prefix_disable != null
#            ? peering.name_prefix_disable == true
#            ? peering.name_postfix_disable != null
#            ? peering.name_postfix_disable == true
#            ? peering.name_idx_enable == null
#            ? "${idx}"
#            : null
#            : null
#            : null
#            : null
#            : null,
#            "${peering.name_prefix}${peering.name_postfix}"
#          )
#        }
#      ]
#    }
#  ]
#}
#
