# ------ Display instructions to connect to the instances
output Instances {
  value = <<EOF

  ---- File Storage filesystem
  The filesystem can be mounted from ${local.mt1_ip_address}:${local.export_path}
  The filesystem is mounted automatically in ${var.fs1_mount_point} on all compute instances by cloud-init 

  ---- You can SSH to the compute instances using the following commands:
  ssh -F sshcfg d04inst01
  ssh -F sshcfg d04inst02

EOF
}

# ------ Create a SSH config file
resource local_file sshconfig {
  content = <<EOF
Host d04inst01
          Hostname ${oci_core_instance.tf-demo04[0].public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file}  
          StrictHostKeyChecking no
          UserKnownHostsFile=/dev/null
Host d04inst02
          Hostname ${oci_core_instance.tf-demo04[1].public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file}  
          StrictHostKeyChecking no
          UserKnownHostsFile=/dev/null
EOF

  filename = "sshcfg"
}

