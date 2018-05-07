
resource "scaleway_ip" "swarm_worker" {
  count = "${var.worker_count}"
}

resource "scaleway_server" "swarm_worker" {
  depends_on=["scaleway_ip.swarm_worker"]

  count = "${var.worker_count}"

  name  = "${var.name} docker swarm worker ${count.index}"
  type  = "${var.type}"

  image = "${data.scaleway_image.debian.id}"
  bootscript = "${data.scaleway_bootscript.mainline.id}"

  tags  = "${concat(local.tags,local.worker_tags)}"

  enable_ipv6=true
  #dynamic_ip_required=true
  public_ip="${element(scaleway_ip.swarm_worker.*.ip,count.index)}"

  security_group="${var.security_group}"

  #TODO: Additional Volumes
}

resource "null_resource" "swarm_worker" {
  depends_on=["scaleway_server.swarm_worker","null_resource.swarm_manager"]

  count = "${scaleway_server.swarm_worker.count}"

  triggers = {
    manager_ips = "${join(",",scaleway_ip.swarm_manager.*.ip)}"
    worker_ips = "${join(",",scaleway_ip.swarm_worker.*.ip)}"
  }

  connection  {
    type = "ssh"
    user = "root"
    #private_key = "${var.use_key_file?file(var.key_file):""}"
    host = "${element(scaleway_server.swarm_worker.*.public_ip,count.index)}"
  }

  provisioner "remote-exec" {
    inline =[
        "sleep 10"
       ,"echo ${count.index} > /tmp/index"
       ,"echo ${var.label} > /tmp/label"
       ,"echo worker > /tmp/role"
       ,"echo '${var.join_existing_swarm?var.existing_swarm_manager:scaleway_server.swarm_manager.0.private_ip}' > /tmp/swarm_manager"
       ,"echo '$(cat /tmp/swarm_manager) swarm_manager' | sudo tee -a /etc/hosts"
    ]
  }

  provisioner "remote-exec" {
    inline=["sudo mkdir -p /opt/keys/manager"]
  }

  provisioner "file" {
    source="keys/${var.name}/${scaleway_server.swarm_manager.0.public_ip}/"
    destination="/opt/keys/manager"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/limits.sh"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/install-docker.sh"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/docker-init-or-join.sh"
  }
}

