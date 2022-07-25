# ------ Create a compute instance in public subnet (Bastion host)
resource oci_core_instance tf-demo02-bastion2 {
  availability_domain  = "ad1"
  compartment_id       = var.compartment_ocid
  display_name         = "tf-cpauliat-demo02-bastion2"
  preserve_boot_volume = "false"
  shape                = var.inst_shape

  source_details {
    source_type             = "image"
    source_id               = var.inst_image
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo02-public-subnet2.id
    hostname_label = "bastion2"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_bastion)
    user_data           = base64encode(file(var.cloudinit_script_bastion))
    myarg_http_proxy    = var.http_proxy
  }
}

