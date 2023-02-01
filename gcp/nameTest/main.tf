# Name generation design
#
# Values:
# network_name = cucumber
# 
# Generated names:
#                        network_name: cucumber
#
#                   subnetwork_0_name: cucumber-subnet-0
# subnetwork_0_secondary_range_name_0: cucumber-subnet-0-secondary-range-0
# subnetwork_0_secondary_range_name_1: cucumber-subnet-0-secondary-range-1
#
#                   subnetwork_0_name: cucumber-subnet-1
#
#--------------------------------------------------------------------------------#
#
# Values:
# network_name_prefix = tomato
#
# Generated names:
#                        network_name: tomato-network
#
#                   subnetwork_0_name: tomato-network-subnet-0
# subnetwork_0_secondary_range_name_0: tomato-network-subnet-0-secondary-range-0
# subnetwork_0_secondary_range_name_1: tomato-network-subnet-0-secondary-range-1
#
#                   subnetwork_1_name: tomato-network-subnet-1
#
#--------------------------------------------------------------------------------#
#
# Values:
#          network_name_prefix = olive
# network_name_postfix_disable = true
#
# Generated names:
#                        network_name: olive
#
#                   subnetwork_0_name: olive-subnet-0
# subnetwork_0_secondary_range_name_0: olive-subnet-0-secondary-range-0
# subnetwork_0_secondary_range_name_1: olive-subnet-0-secondary-range-1
#
#                   subnetwork_1_name: olive-subnet-1
#
#--------------------------------------------------------------------------------#
#
# Values:
#                    network_name_prefix = potato
#           network_name_postfix_disable = true
#               subnetwork_0_name_prefix = banana
# subnetwork_1_secondary_ip_range_prefix = kiwi
#
# Generated names:
#                        network_name: potato
#
#                   subnetwork_0_name: potato-banana-0
# subnetwork_0_secondary_range_name_0: potato-banana-0-secondary-range-0
# subnetwork_0_secondary_range_name_1: potato-banana-0-secondary-range-1
#
#                   subnetwork_1_name: potato-subnet-1
# subnetwork_1_secondary_range_name_0: potato-subnet-0-kiwi-0
# subnetwork_1_secondary_range_name_1: potato-subnet-0-kiwi-1
#
#--------------------------------------------------------------------------------#
#
# Values:
#                            network_name_prefix = potato
#                   network_name_postfix_disable = true
#               subnetwork_0_name_prefix_disable = true
# subnetwork_1_secondary_ip_range_prefix_disable = true
#
# Generated names:
#                        network_name: potato
#
#                   subnetwork_0_name: potato-banana-0
# subnetwork_0_secondary_range_name_0: potato-0-secondary-range-0
# subnetwork_0_secondary_range_name_1: potato-0-secondary-range-1
#
#                   subnetwork_1_name: potato-subnet-1
# subnetwork_1_secondary_range_name_0: potato-subnet-0-0
# subnetwork_1_secondary_range_name_1: potato-subnet-0-1
#
#--------------------------------------------------------------------------------#
#
# Values:
#                 network_name_prefix = potato
#                   subnetwork_0_name = carrot
# subnetwork_0_secondary_range_0_name = plum
#
# Generated names:
#                        network_name: potato-network
#
#                   subnetwork_0_name: potato-network-carrot
# subnetwork_0_secondary_range_name_0: potato-network-carrot-plum
# subnetwork_0_secondary_range_name_1: potato-network-carrot-secondary-range-1
#
#                   subnetwork_1_name: potato-network-subnet-1
# subnetwork_1_secondary_range_name_0: potato-network-subnet-0-secondary-range-0
# subnetwork_1_secondary_range_name_1: potato-network-subnet-0-secondary-range-1
#
#--------------------------------------------------------------------------------#
#
# Notes
# - Remove postfix and postfix_disable from subnetwork and secondary_range, not worth the trouble
# - Add disable_prefix to subnet and secondary ip range
# - It would be nice to be able to output a custom error when neither a network_name or 
#   network_name_prefix are provided but what you get without isn't too bad either
#

variable "network_name" {
  default = null
  type    = string
}

variable "network_name_prefix" {
  default = null
  type    = string
}

variable "network_name_postfix" {
  default = null
  type    = string
}

variable "network_name_postfix_disable" {
  default = null
  type    = bool
}

variable "subnetwork_name" {
  default = null
  type    = string
}

variable "subnetwork_name_prefix" {
  default = null
  type    = string
}

variable "subnetwork_name_prefix_disable" {
  default = null
  type    = string
}

locals {
  network_name = coalesce(
    # If network name was explicitly provided, use as is
    var.network_name,
    # If network name postfix disable was set to true, use network name prefix as is
    var.network_name_postfix_disable != null ? var.network_name_postfix_disable == true ? var.network_name_prefix : null : null,
    # Try returning "network name-network name postfix", return null if 
    # one or the other wasn't provided
    try(
      "${var.network_name_prefix}-${var.network_name_postfix}",
      null
    ),
    # Finally attempt to return "network name-default postfix"
    try(
      "${var.network_name_prefix}${"-network"}",
      null
    )
  )
}

output "network_name" {
  value = local.network_name
}

#output "network_name" {
#  value = coalesce(
#    # If network name was explicitly provided, use as is
#    var.network_name,
#    # If network name postfix disable was set to true, use network name prefix as is
#    var.network_name_postfix_disable != null ? var.network_name_postfix_disable == true ? var.network_name_prefix : null : null,
#    # Try returning "network name-network name postfix", return null if 
#    # one or the other wasn't provided
#    try(
#      "${var.network_name_prefix}-${var.network_name_postfix}",
#      null
#    ),
#    # Finally attempt to return "network name-default postfix"
#    try(
#      "${var.network_name_prefix}${"-network"}",
#      null
#    )
#  )
#}
