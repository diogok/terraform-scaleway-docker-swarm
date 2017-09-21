#!/bin/bash

set -e

ROLE=$(cat /tmp/role)
INDEX=$(cat /tmp/index)
LABEL=$(cat /tmp/label)

if [ "$(docker info -f "{{.Swarm.LocalNodeState}}")" == "active" ]; then
  #sudo docker swarm leave
  #TODO: allow change of manager
  exit 0
fi

if [ "$ROLE" == "manager" ]; then
  if [ "$INDEX" == "0" ]; then
    sudo docker swarm init
  else
    sleep 30
    TOKEN=$(sudo docker -H swarm_manager swarm join-token -q manager)
    sudo docker swarm join swarm_manager:2377 --token $TOKEN
  fi
fi

if [ "$ROLE" == "worker" ]; then
    sleep 30
    TOKEN=$(sudo docker -H swarm_manager swarm join-token -q worker)
    sudo docker swarm join swarm_manager:2377 --token $TOKEN
fi

if [ "$LABEL" != "" ]; then
    sudo docker -H swarm_manager node update --label-add $LABEL $(sudo docker info --format '{{.Swarm.NodeID}}')
fi

