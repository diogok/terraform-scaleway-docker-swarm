#!/bin/bash

set -e

command -v docker && exit 0

sudo apt-get update

sudo apt-get upgrade -y

sudo apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      software-properties-common

curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
  $(lsb_release -cs) \
     stable"

sudo apt-get update
sudo apt-get install docker-ce -y

sed -i -e 's/-H fd:\/\//-H tcp:\/\/0.0.0.0 -H fd:\/\//' /lib/systemd/system/docker.service

sudo systemctl daemon-reload
sudo systemctl restart docker

