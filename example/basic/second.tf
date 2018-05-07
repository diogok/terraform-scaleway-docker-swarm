
module "docker-swarm-db" {
  #source="github.com/diogok/terraform-scaleway-docker-swarm"
  source="../../"
  
  organization="${var.organization}"
  token="${var.token}"

  name="demo"

  label="db=true"

  manager_count=0
  worker_count=1

  join_existing_swarm=true
  existing_swarm_manager="${module.docker-swarm.swarm_managers[0]}"
}

resource "null_resource" "mariadb" {
  depends_on =["module.docker-swarm-db"]
  provisioner "local-exec" {
    command="DOCKER_TLS_VERIFY=1 DOCKER_CERT_PATH=keys/demo/${module.docker-swarm.swarm_managers[0]} DOCKER_HOST=${module.docker-swarm.swarm_managers[0]}:2376 docker service create --name mariadb --replicas 1 --publish 3306:3306 -e \"MYSQL_ROOT_PASSWORD=root\" --constraint=\"node.labels.db==true\"  mariadb"
  }
}

output "mariadb" {
  value="${module.docker-swarm-db.swarm_workers}"
}
