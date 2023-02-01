locals {
  compute_network_names_0 = [
    for network in var.compute_networks : {
      name = coalesce(
        # If network name was explicitly provided, use as is
        network.name,
        # If network name postfix disable was set to true, use network name prefix as is
        network.name_postfix_disable != null ? network.name_postfix_disable == true ? network.name_prefix : null : null,
        # Try returning "network name-network name postfix", return null if 
        # one or the other wasn't provided
        try(
          "${network.name_prefix}-${network.name_postfix}",
          null
        ),
        # Finally attempt to return "network name-default postfix"
        try(
          "${network.name_prefix}-network",
          null
        )
      )
      compute_subnetworks = network.compute_subnetworks == null ? [] : network.compute_subnetworks
    }
  ]
  compute_network_names = [
    for network in local.compute_network_names_0 : {
      compute_subnetwork_names = network.compute_subnetworks == null ? [] : [
        for idx, subnetwork in network.compute_subnetworks : {
          name = coalesce(
            subnetwork.name,
            #coalesce(
            #"${network.name}-${subnetwork.name_prefix_disable != null ? subnetwork.name_prefix_disable == true ? null : subnetwork.name_prefix : subnetwork.name_prefix}-${idx}",
            # TODO Test if this works, the above approaches were giving me grief because of 
            # null values in string interpolation, perhaps I can do something like this instead:
            join(
              "-",
              subnetwork.name_prefix_disable != null ? subnetwork.name_prefix_disable == true ? null : network.name : network.name,
              subnetwork.name_prefix_disable != null ? subnetwork.name_prefix_disable == true ? null : subnetwork.name_prefix : subnetwork.name_prefix,
              subnetwork.name_prefix_disable != null ? subnetwork.name_prefix_disable == true ? null : idx : idx,
            ),
            #),
            try(
              "${network.name}-${subnetwork.name_prefix}-${idx}",
              null
            ),
            try(
              "${network.name}-subnet-${idx}",
              null
            )
          )
        }
      ]
    }
  ]
}

