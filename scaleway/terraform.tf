
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

resource "scaleway_server" "swarm_manager" {
  count = "${var.manager_count}"

  name  = "${var.name} docker swarm manager ${count.index}"
  type  = "${var.type}"

  image = "${data.scaleway_image.debian.id}"
  bootscript = "${data.scaleway_bootscript.mainline.id}"

  tags  = "${concat(local.tags,local.manager_tags)}"

  enable_ipv6=true
  dynamic_ip_required=true

  security_group="${var.security_group}"

  #TODO: Additional Volumes
}

resource "scaleway_server" "swarm_worker" {
  count = "${var.worker_count}"

  name  = "${var.name} docker swarm worker ${count.index}"
  type  = "${var.type}"

  image = "${data.scaleway_image.debian.id}"
  bootscript = "${data.scaleway_bootscript.mainline.id}"

  tags  = "${concat(local.tags,local.worker_tags)}"

  enable_ipv6=true
  dynamic_ip_required=true

  security_group="${var.security_group}"

  #TODO: Additional Volumes
}

resource "null_resource" "swarm_setup" {
  depends_on=["scaleway_server.swarm_manager","scaleway_server.swarm_worker"]

  count = "${scaleway_server.swarm_manager.count + scaleway_server.swarm_worker.count}"

  triggers = {
    manager_ids = "${join(",",scaleway_server.swarm_manager.*.id)}"
    workers_ids = "${join(",",scaleway_server.swarm_worker.*.id)}"
  }

  connection  {
    type = "ssh"
    user = "root"
    #private_key = "${file(var.key_file)}"
    agent = "${var.ssh_agent}"
    host = "${ count.index < var.manager_count
                ? element(scaleway_server.swarm_manager.*.public_ip, count.index) 
                : element(scaleway_server.swarm_worker.*.public_ip, (count.index>0?count.index:1) - var.manager_count) }"
  }

  provisioner "remote-exec" {
    inline =[
        "sleep 10"
       ,"echo ${count.index} > /tmp/index"
       ,"echo ${var.label} > /tmp/label"
       ,"echo ${count.index < var.manager_count?"manager":"worker"}> /tmp/role"
       ,"echo '${var.join_existing_swarm?var.existing_swarm_manager:scaleway_server.swarm_manager.0.private_ip} swarm_manager' | sudo tee -a /etc/hosts"
    ]
  }

  provisioner "remote-exec" {
    script = "${path.module}/../scripts/limits.sh"
  }

  # TODO: Docker TLS

  provisioner "remote-exec" {
    script = "${path.module}/../scripts/install-docker.sh"
  }

  provisioner "remote-exec" {
    script = "${path.module}/../scripts/docker-init-or-join.sh"
  }
}
