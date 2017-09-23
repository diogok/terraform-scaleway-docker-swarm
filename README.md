
# Terraform Docker Swarm Module

_work in progress_

This module creates a docker swarm cluster with TLS enabled.

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

  name="demo"

  manager_count=1
  worker_count=3
  
  label="demo"
  
  # Set provider specifics variables
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

You can control the swarm manager with these commands:

```
$(terraform output docker-env)
```

This will export properlty DOCKER\_HOST , DOCKER\_TLS\_VERIFY and DOCKER\_CERT\_PATH to securily connect docker to the manager.

It will generate the TLS certs at your local "keys" folder.

## Providers

### Scaleway

Needed variables:

  - organization = You access Token
  - token = You generated Token

## License

MIT

