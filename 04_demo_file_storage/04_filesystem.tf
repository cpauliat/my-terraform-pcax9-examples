resource oci_file_storage_file_system tf-demo04-fs1 {
  availability_domain = "ad1"
  compartment_id      = var.compartment_ocid
  display_name        = "tf-demo04-fs1"
}

resource oci_file_storage_mount_target tf-demo04-mt1 {
  availability_domain = "ad1"
  compartment_id      = var.compartment_ocid
  subnet_id           = oci_core_subnet.tf-demo04-public.id
  display_name        = "tf-demo04-mount-target1"
}

resource oci_file_storage_export_set tf-demo04-es1 {
  mount_target_id = oci_file_storage_mount_target.tf-demo04-mt1.id
  display_name    = "tf-demo04-export-set1"
}

resource oci_file_storage_export tf-demo04-fs1-mt1 {
  # ignoring changes as the export path will be different than the requested one
  lifecycle {
    ignore_changes = all
  }

  export_set_id   = oci_file_storage_mount_target.tf-demo04-mt1.export_set_id
  file_system_id  = oci_file_storage_file_system.tf-demo04-fs1.id

  # This path is a mandatory requirement for Terraform, but ignored by PCA X9
  # a random path similar to /export/p6y9gvj09ay74g23uqw1dktoq55gubpzz0myvvfhu4drsoajnlhiuyuxa2wd will be generated
  path            = "/export/ignored"   

  export_options {
    source          = var.cidr_public_subnet
    access          = "READ_WRITE"
    #anonymous_gid   = 99        # nobody
    #anonymous_uid   = 99        # nobody
    identity_squash = "NONE"    # ALL, ROOT or NONE
    require_privileged_source_port = "true"
  }
}

data oci_core_private_ips tf-demo04-mt1 {
  subnet_id = oci_file_storage_mount_target.tf-demo04-mt1.subnet_id

  filter {
    name = "id"
    values = [ oci_file_storage_mount_target.tf-demo04-mt1.private_ip_ids.0 ]
  }
}

locals {
  mt1_ip_address = lookup(data.oci_core_private_ips.tf-demo04-mt1.private_ips[0], "ip_address")
  export_path    = oci_file_storage_export.tf-demo04-fs1-mt1.path
}


