# ------ Display instructions to connect to the instances
output Instances {
  value = <<EOF

  ---- You can SSH to the 2 instances using the following commands:
    ssh -F sshcfg d01bastion
    ssh -F sshcfg d01private

EOF
}

# ------ Create a SSH config file
resource local_file sshconfig {
  content = <<EOF
Host d01bastion
          Hostname ${oci_core_instance.tf-demo01-bastion.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_bastion}  
          StrictHostKeyChecking no
Host d01private
          Hostname ${oci_core_instance.tf-demo01-private.private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_private}  
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d01bastion
EOF

  filename = "sshcfg"
}

