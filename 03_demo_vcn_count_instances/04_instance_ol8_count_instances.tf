# ------ Create several compute instances in public subnet using "count" feature
resource oci_core_instance tf-demo03-instances {
  count                = var.number_of_instances
  availability_domain  = "ad1"
  compartment_id       = var.compartment_ocid
  display_name         = var.instances_name[count.index]
  shape                = var.instances_shape[count.index]
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = var.inst_image
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.tf-demo03-public-subnet1.id
    hostname_label   = var.instances_hostname[count.index]
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
    user_data           = base64encode(file(var.instances_post_prov[count.index]))
    myarg_http_proxy    = var.http_proxy
  }
}

