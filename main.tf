
provider "scaleway" {
  organization="${var.organization}"
  token="${var.token}"
  region="${var.region}"
}

locals {
  default_tags=["docker","swarm"]
  manager_tags=["manager"]
  worker_tags=["worker"]

  tags = "${concat(local.default_tags,var.tags)}"
}

data "scaleway_image" "debian" {
  architecture = "${var.arch}"
  name = "Debian Stretch"
}

data "scaleway_bootscript" "mainline" {
  architecture = "${var.arch}"
  name_filter  = "mainline 4.14.33"
}

