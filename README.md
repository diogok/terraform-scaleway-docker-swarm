
# Terraform Docker Swarm Module

_work in progress_

Still missing a critical security piece: TLS.

This module creates a docker swarm cluster.

Future plan is to create a docker swarm cluster on multiple providers.

## Dependencies

Minimal versions:

- Terraform 0.10.6
- Docker engine 17.06.2-ce

## Usage

```
# provider specific variables to scaleway
variable "organization" {}
variable "token" {}

module "docker-swarm" {
  source="./scaleway" # choose your provider

  name="demo terraform"

  manager_count=1
  worker_count=3
  
  label="demo"
  
  # Set provider specifics variables
  organization="${var.organization}"
  token="${var.token}"
}

# Example service
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
```

## Providers

### Scaleway

Needed variables:

  - organization = You access Token
  - token = You generated Token

## License

MIT

