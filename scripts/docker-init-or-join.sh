#!/bin/bash

set -e

ROLE=$(cat /tmp/role)
INDEX=$(cat /tmp/index)
LABEL=$(cat /tmp/label)
MANAGER=$(cat /tmp/swarm_manager)

if [ "$(docker info -f "{{.Swarm.LocalNodeState}}")" == "active" ]; then
  #sudo docker swarm leave --force
  #TODO: allow change swarm manager
  exit 0
fi

DONE=no
if [ "$ROLE" == "manager" ]; then
  if [ "$INDEX" == "0" ]; then
    echo "Initializing docker swarm"
    docker swarm init
    DONE=yes
    echo "Initialized docker swarm"
  fi
fi

if [ "$DONE" == "no" ]; then
  echo "Joining docker swarm $MANAGER"
  sleep 30
  TOKEN=$(DOCKER_TLS_VERIFY=1 DOCKER_CERT_PATH=/opt/keys/manager DOCKER_HOST=$MANAGER:2376 docker swarm join-token -q $ROLE)
  echo "Joining docker swarm with token $TOKEN as $ROLE"
  docker swarm join $MANAGER:2377 --token $TOKEN
  echo "Joined docker swarm"

  if [ "$LABEL" != "" ]; then
      echo "Adding label $LABEL to current node"
      DOCKER_TLS_VERIFY=1 DOCKER_CERT_PATH=/opt/keys/manager DOCKER_HOST=$MANAGER:2376 docker node update --label-add $LABEL $(sudo docker info --format '{{.Swarm.NodeID}}')
      echo "Added label $LABEL"
  fi
fi

