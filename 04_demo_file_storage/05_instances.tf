# ------ Create 2 compute instances in public subnet 
resource oci_core_instance tf-demo04 {
  count                = 2
  availability_domain  = "ad1"
  compartment_id       = var.compartment_ocid
  display_name         = "tf-cpauliat-demo04-instance${count.index + 1}"
  preserve_boot_volume = "false"
  shape                = var.inst_shape

  source_details {
    source_type = "image"
    source_id   = var.inst_image
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.tf-demo04-public.id
    hostname_label   = "d04inst${count.index + 1}"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys  = file(var.ssh_public_key_file)
    user_data            = base64encode(file(var.cloudinit_script))
    myarg_http_proxy     = var.http_proxy
    myarg_fs_mount_point = var.fs1_mount_point
    myarg_fs_ip_address  = local.mt1_ip_address
    myarg_fs_export_path = local.export_path
  }
}

