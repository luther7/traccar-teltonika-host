resource "tls_private_key" "mtls_private_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "mtls_cert" {
  private_key_pem       = tls_private_key.mtls_private_key.private_key_pem
  validity_period_hours = 87600
  dns_names             = [var.cert_common_name]
  allowed_uses          = ["client_auth"]
}

resource "local_file" "ca_cert" {
  content  = tls_self_signed_cert.mtls_cert.cert_pem
  filename = "out/cert.pem"
}

resource "aws_security_group" "traccar_security_group" {
  name        = "traccar"
  description = "Security group for Traccar"

  tags = {
    Name = "traccar"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_teltonika_ipv4" {
  security_group_id = aws_security_group.traccar_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5052
  to_port           = 5052
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.traccar_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.traccar_security_group.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "traccar_instance" {
  # Ubuntu 24.04 arm64 ap-southeast-2
  ami                         = "ami-0e86a390303d8b431"
  instance_type               = "t4g.small"
  security_groups             = [aws_security_group.traccar_security_group.name]
  associate_public_ip_address = true
  key_name                    = var.ssh_key_name
  user_data_replace_on_change = true

  user_data = templatefile(
    "${path.module}/setup.bash",
    {
      tailscale_authkey = var.tailscale_authkey
    }
  )

  root_block_device {
    encrypted   = true
    volume_size = 30
  }

  volume_tags = {
    Name = "traccar"
  }

  tags = {
    Name = "traccar"
  }
}
