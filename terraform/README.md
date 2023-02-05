# TODO
- Try using labels or networks tags to attach a VM to a subnet
 - Apparently you can't attach either to a subnet
  - Maybe I'll just roll my own tags then
   - Or I could add a standard label to the VM and a custom marker to the subnet
 
# Name generation design
```
 Values:
 network_name = cucumber
 
 Generated names:
                        network_name: cucumber

                   subnetwork_0_name: cucumber-subnet-0
 subnetwork_0_secondary_range_name_0: cucumber-subnet-0-secondary-range-0
 subnetwork_0_secondary_range_name_1: cucumber-subnet-0-secondary-range-1

                   subnetwork_0_name: cucumber-subnet-1
```
---
```
 Values:
 network_name_prefix = tomato

 Generated names:
                        network_name: tomato-network

                   subnetwork_0_name: tomato-network-subnet-0
 subnetwork_0_secondary_range_name_0: tomato-network-subnet-0-secondary-range-0
 subnetwork_0_secondary_range_name_1: tomato-network-subnet-0-secondary-range-1

                   subnetwork_1_name: tomato-network-subnet-1
```
---
```
 Values:
          network_name_prefix = olive
 network_name_postfix_disable = true

 Generated names:
                        network_name: olive

                   subnetwork_0_name: olive-subnet-0
 subnetwork_0_secondary_range_name_0: olive-subnet-0-secondary-range-0
 subnetwork_0_secondary_range_name_1: olive-subnet-0-secondary-range-1

                   subnetwork_1_name: olive-subnet-1
```
---
```
 Values:
                    network_name_prefix = potato
           network_name_postfix_disable = true
               subnetwork_0_name_prefix = banana
 subnetwork_1_secondary_ip_range_prefix = kiwi

 Generated names:
                        network_name: potato

                   subnetwork_0_name: potato-banana-0
 subnetwork_0_secondary_range_name_0: potato-banana-0-secondary-range-0
 subnetwork_0_secondary_range_name_1: potato-banana-0-secondary-range-1

                   subnetwork_1_name: potato-subnet-1
 subnetwork_1_secondary_range_name_0: potato-subnet-0-kiwi-0
 subnetwork_1_secondary_range_name_1: potato-subnet-0-kiwi-1
```
---
```
 Values:
                            network_name_prefix = potato
                   network_name_postfix_disable = true
               subnetwork_0_name_prefix_disable = true
 subnetwork_1_secondary_ip_range_prefix_disable = true

 Generated names:
                        network_name: potato

                   subnetwork_0_name: potato-banana-0
 subnetwork_0_secondary_range_name_0: potato-0-secondary-range-0
 subnetwork_0_secondary_range_name_1: potato-0-secondary-range-1

                   subnetwork_1_name: potato-subnet-1
 subnetwork_1_secondary_range_name_0: potato-subnet-0-0
 subnetwork_1_secondary_range_name_1: potato-subnet-0-1
```
---
```
 Values:
                 network_name_prefix = potato
                   subnetwork_0_name = carrot
 subnetwork_0_secondary_range_0_name = plum

 Generated names:
                        network_name: potato-network

                   subnetwork_0_name: potato-network-carrot
 subnetwork_0_secondary_range_name_0: potato-network-carrot-plum
 subnetwork_0_secondary_range_name_1: potato-network-carrot-secondary-range-1

                   subnetwork_1_name: potato-network-subnet-1
 subnetwork_1_secondary_range_name_0: potato-network-subnet-0-secondary-range-0
 subnetwork_1_secondary_range_name_1: potato-network-subnet-0-secondary-range-1
```
---
```
 Notes
 - Remove postfix and postfix_disable from subnetwork and secondary_range, not worth the trouble
 - Add disable_prefix to subnet and secondary ip range

 PEERINGS NAME GENERATION

 Values:
                 network_name_prefix = potato
                   subnetwork_0_name = carrot
 subnetwork_0_secondary_range_0_name = plum

 Generated names:
                        network_name: potato-network

                   subnetwork_0_name: potato-network-carrot
```
---
```
 Peering names
 Default:
 network_name-to-peer_network_name-peering

 prefix == pearAppleNuts:
 pearAppleNuts-peering

 prefix_disable:
 peering-idx

 prefix_disable, idx_disable:
 peering

 postfix == pairing
 network_name-to-peer_network_name-pairing

 postix_disabled:
 network_name-to-peer_network_name

 prefix_disabled, postfix_disabled:
 idx

 prefix_disabled, potfix_disabled, idx-disabled:
 Can't generate, maybe make it a random string

 peer_network_name_disabled:
 network_name-peering-idx

 peer_network_name_disabled, idx_disabled:
 network_name-peering

 peer_network_name_disabled, idx_disabled, postfix_disabled:
 network_name
```
