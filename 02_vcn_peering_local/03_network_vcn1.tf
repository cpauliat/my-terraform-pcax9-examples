# ------ Create a new VCN
resource oci_core_vcn tf-demo02-vcn1 {
  cidr_block     = var.cidr_vcn1
  compartment_id = var.compartment_ocid
  display_name   = "tf-cpauliat-demo02-vcn1"
  dns_label      = "d02vcn1"
}

# ==================== public subnet

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo02-ig1 {
  compartment_id = var.compartment_ocid
  display_name   = "tf-cpauliat-ig1"
  vcn_id         = oci_core_vcn.tf-demo02-vcn1.id
}

# ------ Create a new Route Table for the public subnet
resource oci_core_route_table tf-demo02-public-rt1 {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo02-vcn1.id
  display_name   = "tf-cpauliat-public-rt1"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.tf-demo02-ig1.id
    description       = "single route rule to Internet gateway for all traffic"
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo02-public-sl1 {
  compartment_id = var.compartment_ocid
  display_name   = "tf-cpauliat-public-seclist1"
  vcn_id         = oci_core_vcn.tf-demo02-vcn1.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn1
  }
  
  ingress_security_rules {
    protocol    = "6" # tcp
    source      = "0.0.0.0/0"
    description = "Allow SSH access to Linux instance from authorized public IP address(es)"
    tcp_options {
      min = 22 
      max = 22
    }
  }
  # ingress_security_rules {
  #   protocol    = "1" # icmp
  #   source      = var.authorized_ips
  #   description = "Needed for MTU. See https://docs.cloud.oracle.com/iaas/Content/Network/Troubleshoot/connectionhang.htm?Highlight=MTU#Path"
  #   icmp_options {
  #     type = 3
  #     code = 4
  #   }
  # }
  
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }
}

# ------ Create a public subnet 
resource oci_core_subnet tf-demo02-public-subnet1 {
  cidr_block          = var.cidr_public1_subnet
  display_name        = "tf-cpauliat-public1"
  dns_label           = "pubnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo02-vcn1.id
  route_table_id      = oci_core_route_table.tf-demo02-public-rt1.id
  security_list_ids   = [oci_core_security_list.tf-demo02-public-sl1.id]
  dhcp_options_id     = oci_core_vcn.tf-demo02-vcn1.default_dhcp_options_id
}

# ==================== private subnet

# ------ Create a NAT gateway
resource oci_core_nat_gateway tf-demo02-natgw1 {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo02-vcn1.id
  display_name   = "tf-cpauliat-natgw1"
}

# ==================== LPG: local peering gateway
resource oci_core_local_peering_gateway tf-demo02-lpg1 {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo02-vcn1.id
  display_name   = "tf-cpauliat-lpg1"
  peer_id        = oci_core_local_peering_gateway.tf-demo02-lpg2.id
}

# # ------ Create a new Services Gategay to access Oracle services from private subnet
# # different from OCI: no "All services" service
# data oci_core_services services {
#   filter {
#     name   = "name"
#     values = ["api"]
#     regex  = true
#   }
# }

# resource oci_core_service_gateway tf-demo02-sgw {
#   compartment_id = var.compartment_ocid
#   vcn_id         = oci_core_vcn.tf-demo02-vcn1.id
#   services {
#     service_id = lookup(data.oci_core_services.services.services[0], "id")
#   }
#   display_name   = "tf-cpauliat-svcgw"
# }

# ------ Create a new Route Table for the private subnet
resource oci_core_route_table tf-demo02-private-rt1 {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo02-vcn1.id
  display_name   = "tf-cpauliat-private-rt1"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.tf-demo02-natgw1.id
    description       = "default route rule to NAT gateway"
  }

  route_rules {
    destination       = var.cidr_private2_subnet
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.tf-demo02-lpg1.id
    description       = "route to peered VCN"
  }

  # route_rules {
  #   destination       = "???"
  #   destination_type  = "SERVICE_CIDR_BLOCK"
  #   network_entity_id = oci_core_service_gateway.tf-demo02-sgw.id
  #   description       = "route rule for API access"
  # }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo02-private-sl1 {
  compartment_id = var.compartment_ocid
  display_name   = "tf-cpauliat-private-seclist1"
  vcn_id         = oci_core_vcn.tf-demo02-vcn1.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn1
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn2
  }

  # ingress_security_rules {
  #   protocol    = "6" # tcp
  #   source      = var.authorized_ips
  #   description = "Allow SSH access to Linux instance from authorized public IP address(es)"
  #   tcp_options {
  #     min = 22 
  #     max = 22
  #   }
  # }
  # ingress_security_rules {
  #   protocol    = "1" # icmp
  #   source      = var.authorized_ips
  #   description = "Needed for MTU. See https://docs.cloud.oracle.com/iaas/Content/Network/Troubleshoot/connectionhang.htm?Highlight=MTU#Path"
  #   icmp_options {
  #     type = 3
  #     code = 4
  #   }
  # }
}

# ------ Create a private subnet 
resource oci_core_subnet tf-demo02-private1 {
  cidr_block          = var.cidr_private1_subnet
  display_name        = "tf-cpauliat-private1"
  dns_label           = "privnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo02-vcn1.id
  route_table_id      = oci_core_route_table.tf-demo02-private-rt1.id
  security_list_ids   = [oci_core_security_list.tf-demo02-private-sl1.id]
  dhcp_options_id     = oci_core_vcn.tf-demo02-vcn1.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}

