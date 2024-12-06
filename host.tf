data "http" "ipify" {
  url = "https://api.ipify.org"
}

resource "aws_security_group" "traccar_server_security_group" {
  name = "traccar"
  tags = var.aws_tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_teltonika_ipv4_tls" {
  security_group_id = aws_security_group.traccar_server_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5200
  to_port           = 5200
  ip_protocol       = "tcp"
}

# https://github.com/tailscale/tailscale/issues/12409
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.traccar_server_security_group.id
  cidr_ipv4         = "${data.http.ipify.response_body}/32"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.traccar_server_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.traccar_server_security_group.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_ebs_volume" "traccar_storage" {
  availability_zone = var.aws_availability_zone
  size              = var.aws_storage_volume_size
  encrypted         = true
  tags              = var.aws_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "tailscale_tailnet_key" "traccar_server_key" {
  reusable            = true
  ephemeral           = true
  preauthorized       = true
  recreate_if_invalid = "always"
  expiry              = 3600
  description         = "Traccar server key"
  tags                = var.tailscale_tags
}

resource "aws_instance" "traccar_server_instance" {
  ami                         = var.aws_ami
  availability_zone           = var.aws_availability_zone
  instance_type               = var.aws_instance_type
  security_groups             = [aws_security_group.traccar_server_security_group.name]
  key_name                    = var.aws_ssh_key_name
  associate_public_ip_address = true
  user_data_replace_on_change = true
  volume_tags                 = var.aws_tags
  tags                        = var.aws_tags

  user_data = templatefile(
    "${path.module}/setup-server.bash",
    {
      tailscale_authkey   = tailscale_tailnet_key.traccar_server_key.key
      tailscale_hostname  = var.tailscale_hostname
      storage_volume_size = var.aws_storage_volume_size
    }
  )

  root_block_device {
    encrypted   = true
    volume_size = var.aws_root_volume_size
  }
}

resource "aws_volume_attachment" "traccar_server_storage_ebs_attachment" {
  device_name                    = "/dev/sdf"
  volume_id                      = aws_ebs_volume.traccar_storage.id
  instance_id                    = aws_instance.traccar_server_instance.id
  stop_instance_before_detaching = true
}

