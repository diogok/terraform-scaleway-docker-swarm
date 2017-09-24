#!/bin/bash

set -e

command -v docker && exit 0 # Exit if docker already installed

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

ROLE=$(cat /tmp/role)
if [ "$ROLE" == "manager" ]; then
  echo "Setting up TLS on manager"
  OPTS='-H0.0.0.0:2376 -H fd:\/\/ --tlsverify --tlscacert=\/opt\/keys\/ca.pem --tlscert=\/opt\/keys\/server-cert.pem --tlskey=\/opt\/keys\/server-key.pem'
  sed -i -e "s/-H fd:\/\//$OPTS/" /lib/systemd/system/docker.service
  sudo systemctl daemon-reload
  sudo systemctl restart docker
fi

