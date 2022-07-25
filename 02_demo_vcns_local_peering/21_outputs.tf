# ------ Display instructions to connect to the instances
output Instances {
  value = <<EOF

  ---- You can SSH to the 4 instances using the following commands:
    ssh -F sshcfg d02bastion1
    ssh -F sshcfg d02private1
    ssh -F sshcfg d02bastion2
    ssh -F sshcfg d02private2

  --- To test VCN peering between subnets private1 (VCN1) and private2 (VCN2), execute the following commands:
    ssh -F sshcfg d02private1
    ping ${oci_core_instance.tf-demo02-private2.private_ip}   (private IP for private2 instance)

    ssh -F sshcfg d02private2
    ping ${oci_core_instance.tf-demo02-private1.private_ip}   (private IP for private1 instance)

EOF
}

# ------ Create a SSH config file
resource local_file sshconfig {
  content = <<EOF
Host d02bastion1
          Hostname ${oci_core_instance.tf-demo02-bastion1.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_bastion}  
          StrictHostKeyChecking no
          UserKnownHostsFile=/dev/null
Host d02private1
          Hostname ${oci_core_instance.tf-demo02-private1.private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_private}  
          StrictHostKeyChecking no
          UserKnownHostsFile=/dev/null
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d02bastion1
Host d02bastion2
          Hostname ${oci_core_instance.tf-demo02-bastion2.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_bastion}  
          StrictHostKeyChecking no
          UserKnownHostsFile=/dev/null
Host d02private2
          Hostname ${oci_core_instance.tf-demo02-private2.private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_private}  
          StrictHostKeyChecking no
          UserKnownHostsFile=/dev/null
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d02bastion2
EOF

  filename = "sshcfg"
}

