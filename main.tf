
provider "scaleway" {
  organization="${var.organization}"
  token="${var.token}"
  region="${var.region}"
}

locals {
  archs={
    "ARM64-2G"="arm64"
    "ARM64-4G"="arm64"
    "ARM64-8G"="arm64"
    "ARM64-16G"="arm64"
    "ARM64-32G"="arm64"
    "ARM64-64G"="arm64"
    "ARM64-128G"="arm64"
    "VC1S"="x86_64"
    "VC1M"="x86_64"
    "VC1L"="x86_64"
    "X64-15GB"="x86_64"
    "X64-30GB"="x86_64"
    "X64-60GB"="x86_64"
    "X64-120GB"="x86_64"
    "C1"="arm"
    "C2S"="x86_64"
    "C2M"="x86_64"
    "C2L"="x86_64"
    # TODO: there is probably a better way to list architecture of machine types
  }

  arch="${lookup(local.archs,var.type)}"

  default_tags=["docker","swarm"]
  manager_tags=["manager"]
  worker_tags=["worker"]

  tags = "${concat(local.default_tags,var.tags)}"
}

data "scaleway_image" "ubuntu" {
  architecture = "${local.arch}"
  name = "Ubuntu Xenial"
}

data "scaleway_image" "debian" {
  architecture = "${local.arch}"
  name = "Debian Stretch"
}

data "scaleway_bootscript" "mainline" {
  architecture = "${local.arch}"
  name_filter  = "mainline 4.9.49"
}

