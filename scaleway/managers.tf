
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

resource "null_resource" "swarm_manager" {
  depends_on=["scaleway_server.swarm_manager"]

  count = "${scaleway_server.swarm_manager.count}"

  triggers = {
    manager_ids = "${join(",",scaleway_server.swarm_manager.*.id)}"
  }

  connection  {
    type = "ssh"
    user = "root"
    #private_key = "${var.use_key_file?file(var.key_file):""}"
    agent = "${var.ssh_agent}"
    host = "${element(scaleway_server.swarm_manager.*.public_ip,count.index)}"
  }

  provisioner "remote-exec" {
    inline =[
        "sleep 10"
       ,"echo ${count.index} > /tmp/index"
       ,"echo ${var.label} > /tmp/label"
       ,"echo manager > /tmp/role"
       ,"echo '${var.join_existing_swarm?var.existing_swarm_manager:scaleway_server.swarm_manager.0.private_ip}' > /tmp/swarm_manager"
       ,"echo '$(cat /tmp/swarm_manager) swarm_manager' | sudo tee -a /etc/hosts"
    ]
  }

  provisioner "local-exec" {
    command=<<EOF
docker run \
  -v "$PWD/keys/${var.name}/${element(scaleway_server.swarm_manager.*.public_ip,count.index)}:/opt/keys" \
  -v "$PWD/scripts:/opt/scripts" \
  centurylink/openssl \
  sh /opt/scripts/create-docker-tls.sh /opt/keys localhost ${element(scaleway_server.swarm_manager.*.public_ip,count.index)} ${element(scaleway_server.swarm_manager.*.private_ip,count.index)}
EOF
  }

  provisioner "remote-exec" {
    inline=["sudo mkdir -p /opt/keys/manager"]
  }

  provisioner "file" {
    source="keys/${var.name}/${element(scaleway_server.swarm_manager.*.public_ip,count.index)}/"
    destination="/opt/keys"
  }

  provisioner "file" {
    source="keys/${var.name}/${scaleway_server.swarm_manager.0.public_ip}/"
    destination="/opt/keys/manager"
  }

  provisioner "remote-exec" {
    script = "${path.module}/../scripts/limits.sh"
  }

  provisioner "remote-exec" {
    script = "${path.module}/../scripts/install-docker.sh"
  }

  provisioner "remote-exec" {
    script = "${path.module}/../scripts/docker-init-or-join.sh"
  }
}