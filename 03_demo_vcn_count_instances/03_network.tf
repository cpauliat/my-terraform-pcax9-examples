# ------ Create a new VCN
resource oci_core_vcn tf-demo03-vcn {
  cidr_block     = var.cidr_vcn
  compartment_id = var.compartment_ocid
  display_name   = "tf-cpauliat-demo03-vcn"
  dns_label      = "d03vcn"
}

# ==================== public subnet

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo03-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-cpauliat-ig"
  vcn_id         = oci_core_vcn.tf-demo03-vcn.id
}

# ------ Create a new Route Table for the public subnet
resource oci_core_route_table tf-demo03-public-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo03-vcn.id
  display_name   = "tf-cpauliat-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.tf-demo03-ig.id
    description       = "single route rule to Internet gateway for all traffic"
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo03-public-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-cpauliat-public-seclist"
  vcn_id         = oci_core_vcn.tf-demo03-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn
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
resource oci_core_subnet tf-demo03-public-subnet1 {
  cidr_block          = var.cidr_public_subnet
  display_name        = "tf-cpauliat-public"
  dns_label           = "pubnet"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo03-vcn.id
  route_table_id      = oci_core_route_table.tf-demo03-public-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo03-public-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo03-vcn.default_dhcp_options_id
}

# ==================== private subnet

# ------ Create a NAT gateway
resource oci_core_nat_gateway tf-demo03-natgw {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo03-vcn.id
  display_name   = "tf-cpauliat-natgw"
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

# resource oci_core_service_gateway tf-demo03-sgw {
#   compartment_id = var.compartment_ocid
#   vcn_id         = oci_core_vcn.tf-demo03-vcn.id
#   services {
#     service_id = lookup(data.oci_core_services.services.services[0], "id")
#   }
#   display_name   = "tf-cpauliat-svcgw"
# }

# ------ Create a new Route Table for the private subnet
resource oci_core_route_table tf-demo03-private-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo03-vcn.id
  display_name   = "tf-cpauliat-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.tf-demo03-natgw.id
    description       = "default route rule to NAT gateway"
  }

  # route_rules {
  #   destination       = "???"
  #   destination_type  = "SERVICE_CIDR_BLOCK"
  #   network_entity_id = oci_core_service_gateway.tf-demo03-sgw.id
  #   description       = "route rule for API access"
  # }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo03-private-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-cpauliat-private-seclist"
  vcn_id         = oci_core_vcn.tf-demo03-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outgoing traffic"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.cidr_vcn
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
resource oci_core_subnet tf-demo03-private {
  cidr_block          = var.cidr_private_subnet
  display_name        = "tf-cpauliat-private"
  dns_label           = "privnet"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo03-vcn.id
  route_table_id      = oci_core_route_table.tf-demo03-private-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo03-private-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo03-vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}

