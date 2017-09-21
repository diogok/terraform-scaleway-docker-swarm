
variable "organization" {}
variable "token" {}

module "docker-swarm" {
  source="./scaleway"
  
  organization="${var.organization}"
  token="${var.token}"

  name="demo terraform"

  manager_count=1
  worker_count=3
  
  label="demo"
}

resource "null_resource" "nginx" {
  depends_on =["module.docker-swarm"]
  provisioner "local-exec" {
    command="DOCKER_HOST=${module.docker-swarm.swarm_managers[0]} docker service create --name nginx --replicas 3 --publish 80:80 nginx"
  }
}

output "managers" {
  value="${module.docker-swarm.swarm_managers}"
}

output "workers" {
  value="${module.docker-swarm.swarm_workers}"
}

