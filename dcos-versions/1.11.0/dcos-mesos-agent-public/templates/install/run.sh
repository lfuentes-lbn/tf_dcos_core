#!/bin/sh

# exit 0 if an already installed dcos is there
systemctl is-active --quiet dcos-* && echo "DC/OS seems already installed on $HOSTNAME, exit O" && exit 0

# Install Agent Node
mkdir /tmp/dcos && cd /tmp/dcos
/usr/bin/curl -O ${bootstrap_private_ip}:${dcos_bootstrap_port}/dcos_install.sh
bash dcos_install.sh slave_public
# Agent Node End
