#!/bin/bash
#
# Heavily based on https://gist.githubusercontent.com/Stono/7e6fed13cfd79598eb15/raw/dab92ccd1ff8dc1737ea82830e1018356dee4e4a/create-docker-tls.sh
#
# MIT License.
#

set -e
STR=4096

DIR=$1
DOCKER_HOST=$2
PUBLIC_IP=$3
PRIVATE_IP=$4

echo " => Using hostname: '$DOCKER_HOST' and 'swarm_manager' and IP: '$PUBLIC_IP' and IP: '$PRIVATE_IP'. You MUST connect to docker using this host or ip!"

echo " => Ensuring config directory '$DIR' exists..."
#DIR="$PWD/keys"
mkdir -p "$DIR"
cd $DIR

echo " => Verifying ca.srl"
if [ ! -f "ca.srl" ]; then
  echo " => Creating ca.srl"
  echo 01 > ca.srl
else
  echo "Keys exist. Done nothing."
  exit 0
fi

echo " => Generating CA key"
openssl genrsa \
  -out ca-key.pem $STR

echo " => Generating CA certificate"
openssl req \
  -new \
  -x509 \
  -days 3650 \
  -key ca-key.pem \
  -nodes \
  -subj "/CN=$DOCKER_HOST" \
  -out ca.pem

echo " => Generating server key"
openssl genrsa \
  -out server-key.pem $STR

echo " => Generating server CSR"
openssl req \
  -subj "/CN=$DOCKER_HOST" \
  -new \
  -key server-key.pem \
  -out server.csr

echo " => Something about DNS vs IP"
echo subjectAltName = DNS:$DOCKER_HOST,DNS:swarm_manager,IP:$PUBLIC_IP,IP:$PRIVATE_IP,IP:127.0.0.1 > extfile.cnf
echo extendedKeyUsage = serverAuth >> extfile.cnf

echo " => Signing server CSR with CA"
openssl x509 \
  -req \
  -days 3650 \
  -in server.csr \
  -CA ca.pem \
  -CAkey ca-key.pem \
  -CAcreateserial \
  -out server-cert.pem \
  -extfile extfile.cnf

echo " => Generating client key"
openssl genrsa \
  -out key.pem $STR

echo " => Generating client CSR"
openssl req \
  -subj "/CN=client" \
  -new \
  -key key.pem \
  -out client.csr

echo " => Creating extended key usage"
echo extendedKeyUsage = clientAuth >> extfile.cnf

echo " => Signing client CSR with CA"
openssl x509 \
  -req \
  -days 3650 \
  -in client.csr \
  -CA ca.pem \
  -CAkey ca-key.pem \
  -CAcreateserial \
  -out cert.pem \
  -extfile extfile.cnf

echo " =>   You will need to set the following environment variables before running the docker client:"
echo " =>   DOCKER_HOST=tcp://$PUBLIC_IP:2376"
echo " =>   DOCKER_TLS_VERIFY=1"
echo " =>   DOCKER_CERT_PATH=$DIR"

OPTIONS="--tlsverify --tlscacert=$DIR/ca.pem --tlscert=$DIR/server-cert.pem --tlskey=$DIR/server-key.pem -H=0.0.0.0:2376"
echo " =>   You will need to configure your docker daemon with the following options:"
echo " =>   $OPTIONS" 

