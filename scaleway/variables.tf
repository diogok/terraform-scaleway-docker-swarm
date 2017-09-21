
variable "organization" {}

variable "token" {}

variable "region" {
  default="par1"
}

variable "type" {
  default="VC1S"
}

variable "name" {
  default="My Service"
}

variable "tags" {
  default=[]
}

variable "manager_count" {
  default=1
}

variable "worker_count" {
  default=3
}

variable "additional_volume_size" {
  default="50"
}

variable "security_group" {
  default=""
}

variable "key_file" {
  default=""
}

variable "ssh_agent" {
  default=true
}

variable "label" {
  default=""
}

variable "join_existing_swarm" {
  default=false
}

variable "existing_swarm_manager" {
  default=""
}
