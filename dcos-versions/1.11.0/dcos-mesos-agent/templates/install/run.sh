#!/bin/sh

# exit 0 if an already installed dcos is there
systemctl is-active --quiet dcos-* && echo "DC/OS seems already installed on $HOSTNAME, exit O" && exit 0

# Check if data disk size is greater
# than 1 Gib for create /var/lib/mesos with it
size=$(parted /dev/sdc unit gib print | awk '/^D.*\/dev\/sdc/ {split($NF,size,"GiB"); printf "%s",size[1]}' | cut -d'.' -f1)
if [ $size -gt 1 ]; then
    echo "optional data disk for mesos is more than 1GiB"

    echo "creating PV on it..."
    pvcreate /dev/sdc
    
    echo "creating VG on PV..."
    vgcreate VGMESOS /dev/sdc

    echo "creating LV on VG..."
    lvcreate -n lvmesos -l+100%FREE VGMESOS

    echo "formating FS on LV..."
    mkfs.ext4 /dev/mapper/VGMESOS-lvmesos

    echo "adding line in /etc/fstab"
    echo -e "/dev/mapper/VGMESOS-lvmesos\t/var/lib/mesos\text4\tdefaults\t0 2" >> /etc/fstab

    echo "creating /var/lib/mesos for mounting..."
    mkdir /var/lib/mesos

    echo "mouting..."
    mount -a
    chmod 755 /var/lib/mesos
fi

# Install Agent Node
mkdir /tmp/dcos && cd /tmp/dcos
/usr/bin/curl -O ${bootstrap_private_ip}:${dcos_bootstrap_port}/dcos_install.sh
bash dcos_install.sh slave
# Agent Node End

