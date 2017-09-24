# Terraform Scaleway Docker Swarm Module

This module creates a docker swarm cluster with TLS enabled on Scaleway.

It does not create network security groups, docker access is secured using TLS certificates but creating network security groups is up to you.

Still to do:

- Support choosing a key file for ssh. Right now it trusts you local ssh agent.
- Support joining an existing docker swarm.
- Support additional volumes.
- Support bastion hosts to provision instances.

## Dependencies

Minimal versions:

- Terraform 0.10.6
- Docker engine 17.06.2-ce
- An scaleway account

## Usage

Example usage of the module.

```
# scaleway access variables
variable "organization" {}
variable "token" {}

module "docker-swarm" {
  source="github.com/diogok/terraform-scaleway-docker-swarm" 

  name="demo"

  manager_count=1
  worker_count=3
  
  label="demo"
  
  organization="${var.organization}"
  token="${var.token}"
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
```

You can control the swarm manager with this command:

```
$(terraform output docker-env)
```

This will export properlty DOCKER\_HOST , DOCKER\_TLS\_VERIFY and DOCKER\_CERT\_PATH to securily connect docker to the manager.

It will generate the TLS certs at your local "keys" folder, on folder for each name and one folder for each IP of a manager. Only manager get docker daemon exposed.

## License

MIT

