
variable "organization" {}
variable "token" {}

module "docker-swarm" {
  #source="github.com/diogok/terraform-scaleway-docker-swarm"
  source="../../"
  
  organization="${var.organization}"
  token="${var.token}"

  name="demo"

  label="demo"

  manager_count=2
  worker_count=3
}

resource "null_resource" "nginx" {
  depends_on =["module.docker-swarm"]
  provisioner "local-exec" {
    command="DOCKER_TLS_VERIFY=1 DOCKER_CERT_PATH=keys/demo/0 DOCKER_HOST=${module.docker-swarm.swarm_managers[0]}:2376 docker service create --name nginx --replicas 1 --publish 80:80 nginx"
  }
}

output "managers" {
  value="${module.docker-swarm.swarm_managers}"
}

output "workers" {
  value="${module.docker-swarm.swarm_workers}"
}

output "docker-env" {
  value="${module.docker-swarm.docker-env}"
}

