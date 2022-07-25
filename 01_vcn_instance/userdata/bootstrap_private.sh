#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

touch /home/opc/CLOUD-INIT

echo "========== Get argument(s) passed thru metadata"
PROXY=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_http_proxy`
MOUNT_PT=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_mount_point`

echo "========== Configure YUM proxy"
echo "proxy=${PROXY}" >> /etc/yum.conf
sleep 2

echo "========== Install additional packages"
yum install zsh -y

echo "========== Storage setup: create and mount filesystem"
DSK_NAME="/dev/sdb"
mkfs.xfs $DSK_NAME
mkdir $MOUNT_PT
mount -t xfs $DSK_NAME $MOUNT_PT
echo "$DSK_NAME    $MOUNT_PT    xfs    defaults,noatime,_netdev,nofail" >> /etc/fstab
chown opc:opc $MOUNT_PT

# echo "========== Apply latest updates to Linux OS"
# yum update -y

# echo "========== Final reboot"
# reboot