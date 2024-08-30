data "http" "ipify" {
  url = "https://api.ipify.org"
}

resource "aws_security_group" "traccar_host_security_group" {
  name = "traccar-host"

  tags = {
    Name = "traccar-host"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_teltonika_ipv4" {
  security_group_id = aws_security_group.traccar_host_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5052
  to_port           = 5052
  ip_protocol       = "tcp"
}

# https://github.com/tailscale/tailscale/issues/12409
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.traccar_host_security_group.id
  cidr_ipv4         = "${data.http.ipify.response_body}/32"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.traccar_host_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.traccar_host_security_group.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_ebs_volume" "traccar_storage" {
  availability_zone = var.availability_zone
  size              = var.storage_volume_size
  encrypted         = true

  tags = {
    Name = "traccar-host"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_instance" "traccar_host_instance" {
  # Ubuntu 24.04 arm64 ap-southeast-2
  ami                         = var.ami
  availability_zone           = var.availability_zone
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.traccar_host_security_group.name]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true
  user_data_replace_on_change = false

  user_data = templatefile(
    "${path.module}/setup-host.bash",
    { tailscale_authkey = var.tailscale_authkey }
  )

  root_block_device {
    encrypted   = true
    volume_size = var.root_volume_size
  }

  volume_tags = {
    Name = "traccar-host"
  }

  tags = {
    Name = "traccar-host"
  }
}

resource "aws_volume_attachment" "traccar_host_storage_ebs_attachment" {
  device_name                    = "/dev/sdf"
  volume_id                      = aws_ebs_volume.traccar_storage.id
  instance_id                    = aws_instance.traccar_host_instance.id
  stop_instance_before_detaching = true
}

