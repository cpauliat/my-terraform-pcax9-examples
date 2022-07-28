# ------ Create a block volume
resource oci_core_volume tf-demo01-vol1 {
  # error when re-run tf apply: │ Error Message: New size should be larger than current Volume size
  lifecycle {
    ignore_changes = all
  }
  availability_domain = "ad1"
  compartment_id      = var.compartment_ocid
  display_name        = "tf-cpauliat-vol1"
  size_in_gbs         = "50"
}

# ------ Attach the new block volume to the ol7 compute instance after it is created
resource oci_core_volume_attachment tf-demo01-vol1-attach {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.tf-demo01-private.id
  volume_id       = oci_core_volume.tf-demo01-vol1.id
}

# ------ Create a compute instance in private subnet
resource oci_core_instance tf-demo01-private {
  availability_domain  = "ad1"
  compartment_id       = var.compartment_ocid
  display_name         = "tf-cpauliat-demo01-private"
  preserve_boot_volume = "false"
  shape                = var.inst_shape

  source_details {
    source_type             = "image"
    source_id               = var.inst_image
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo01-private-subnet.id
    hostname_label = "private"
    assign_public_ip = false
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_private)
    user_data           = base64encode(file(var.cloudinit_script_private))
    myarg_http_proxy    = var.http_proxy
    myarg_mount_point   = var.mount_point
  }
}

