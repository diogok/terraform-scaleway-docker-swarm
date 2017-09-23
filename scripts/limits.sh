#!/bin/bash

set -e

if [ "$(sudo sysctl fs.file-max)" == "fs.file-max = 65536" ]; then
  exit 0
fi

sudo sysctl -w vm.max_map_count=262144
echo vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf

sudo sysctl -w fs.file-max=65536
echo fs.file-max=65536 | sudo tee -a /etc/sysctl.conf

