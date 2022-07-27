# ------ Create a new VCN
resource oci_core_vcn tf-demo04-vcn {
  cidr_block     = var.cidr_vcn
  compartment_id = var.compartment_ocid
  display_name   = "tf-cpauliat-demo04-vcn"
  dns_label      = "d04vcn"
}

# ==================== public subnet

# ------ Create a new Internet Gategay
resource oci_core_internet_gateway tf-demo04-ig {
  compartment_id = var.compartment_ocid
  display_name   = "tf-cpauliat-ig"
  vcn_id         = oci_core_vcn.tf-demo04-vcn.id
}

# ------ Create a new Route Table for the public subnet
resource oci_core_route_table tf-demo04-public-rt {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf-demo04-vcn.id
  display_name   = "tf-cpauliat-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.tf-demo04-ig.id
    description       = "single route rule to Internet gateway for all traffic"
  }
}

# ------ Create a new security list to be used in the new subnet
resource oci_core_security_list tf-demo04-public-sl {
  compartment_id = var.compartment_ocid
  display_name   = "tf-cpauliat-public-seclist"
  vcn_id         = oci_core_vcn.tf-demo04-vcn.id

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
resource oci_core_subnet tf-demo04-public {
  cidr_block          = var.cidr_public_subnet
  display_name        = "tf-cpauliat-public"
  dns_label           = "pubnet"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf-demo04-vcn.id
  route_table_id      = oci_core_route_table.tf-demo04-public-rt.id
  security_list_ids   = [oci_core_security_list.tf-demo04-public-sl.id]
  dhcp_options_id     = oci_core_vcn.tf-demo04-vcn.default_dhcp_options_id
}