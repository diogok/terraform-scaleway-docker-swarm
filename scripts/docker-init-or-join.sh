#!/bin/bash

set -e

ROLE=$(cat /tmp/role)
INDEX=$(cat /tmp/index)
LABEL=$(cat /tmp/label)
MANAGER=$(cat /tmp/swarm_manager)

if [ "$(docker info -f "{{.Swarm.LocalNodeState}}")" == "active" ]; then
  #sudo docker swarm leave
  #TODO: allow change of manager
  exit 0
fi

DONE=no
if [ "$ROLE" == "manager" ]; then
  if [ "$INDEX" == "0" ]; then
    echo "Initing docker swarm"
    docker swarm init
    DONE=yes
    echo "Init docker swarm done"
  fi
fi

if [ "$DONE" == "no" ]; then
  echo "Joining docker swarm"
  sleep 30
  TOKEN=$(DOCKER_TLS_VERIFY=1 DOCKER_CERT_PATH=/opt/keys/manager DOCKER_HOST=$MANAGER:2376 docker swarm join-token -q $ROLE)
  echo "Joining docker swarm token $TOKEN"
  docker swarm join $MANAGER:2377 --token $TOKEN
  echo "Joined docker swarm"

  if [ "$LABEL" != "" ]; then
      DOCKER_TLS_VERIFY=1 DOCKER_CERT_PATH=/opt/keys/manager DOCKER_HOST=$MANAGER:2376 docker node update --label-add $LABEL $(sudo docker info --format '{{.Swarm.NodeID}}')
  fi
fi

