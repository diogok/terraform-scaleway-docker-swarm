
# Terraform docker swarm on Scaleway

This is an example on how to use the terraform-scaleway-docker-swarm module.

Take a look at the main.tf, variables.tf and output.tf.

## Usage

Copy "terraform.tfvars.dist" to "terraform.tfvars" and fill in the "organization" variable with you access token and the "token" variable with your generated token.

Once "terraform apply" executes it will create the configured cluster and store the generated TLS keys needed to control the swarm at a local "keys" folder. Make sure to keep this folder around but out of version control.

You can control the swarm manager by issuing "${terraform output docker-env}" and them all docker commands will be using the first manager.

## LICENSE

MIT

