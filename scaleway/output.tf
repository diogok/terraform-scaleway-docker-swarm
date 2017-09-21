
output "swarm_managers" {
  value=["${scaleway_server.swarm_manager.*.public_ip}"]
}

output "swarm_workers" {
  value=["${scaleway_server.swarm_worker.*.public_ip}"]
}
