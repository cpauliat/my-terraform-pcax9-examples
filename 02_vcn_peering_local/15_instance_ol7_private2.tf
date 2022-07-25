# ------ Create a compute instance in private subnet
resource oci_core_instance tf-demo02-private2 {
  availability_domain  = "ad1"
  compartment_id       = var.compartment_ocid
  display_name         = "tf-cpauliat-demo02-private2"
  preserve_boot_volume = "false"
  shape                = var.inst_shape

  source_details {
    source_type             = "image"
    source_id               = var.inst_image
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.tf-demo02-private2.id
    hostname_label   = "private2"
    assign_public_ip = false
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_private)
    user_data           = base64encode(file(var.cloudinit_script_private))
    myarg_http_proxy    = var.http_proxy
  }
}

