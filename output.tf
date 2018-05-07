
output "swarm_managers" {
  description="Public IPs of the swarm managers"
  value=["${scaleway_ip.swarm_manager.*.ip}"]
}

output "swarm_workers" {
  description="Public IPs of the swarm workers"
  value=["${scaleway_ip.swarm_worker.*.ip}"]
}

output "docker-env" {
  description="Environment variables setup to control the swarm locally. Just call as $(terraform output docker-env)."
  value =<<EOF
export DOCKER_HOST=${local.manager}:2376
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=keys/${var.name}/${local.manager}
EOF
}

