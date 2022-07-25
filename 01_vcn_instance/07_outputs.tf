# ------ Display the complete ssh command needed to connect to the instance
output Instances {
  value = <<EOF

  ---- The IP addresses assigned to the bastion instance are : 
  private IP: ${oci_core_instance.tf-demo01-bastion.private_ip}
  public IP : ${oci_core_instance.tf-demo01-bastion.public_ip}
  
  ---- The IP address assigned to the private instance is : 
  private IP: ${oci_core_instance.tf-demo01-private.private_ip}

  ---- You can SSH to the 2 instances using the following commands:
    ssh -F sshcfg d02bastion
    ssh -F sshcfg d02private

EOF
}

# ------ Create a SSH config file
resource local_file sshconfig {
  content = <<EOF
Host d02bastion
          Hostname ${oci_core_instance.tf-demo01-bastion.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_bastion}  
          StrictHostKeyChecking no
Host d02private
          Hostname ${oci_core_instance.tf-demo01-private.private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_private}  
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d02bastion
EOF

  filename = "sshcfg"
}

