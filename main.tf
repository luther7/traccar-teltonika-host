resource "random_password" "mysql_password" {
  length     = 32
  special = true
}

resource "tailscale_tailnet_key" "traccar_key" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 3600
  description   = "Traccar key"
  tags          = var.tailscale_tags
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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "traccar_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3a.micro"
  security_groups             = [aws_security_group.traccar_security_group.name]
  associate_public_ip_address = true
  key_name                    = var.ssh_key_name
  user_data_replace_on_change = true

  user_data = templatefile(
    "${path.module}/setup.bash",
    {
      mysql_password       = random_password.mysql_password.result
      cloudflare_api_token = var.cloudflare_api_token
      tailscale_auth_key   = tailscale_tailnet_key.traccar_key.key
      dns_zone             = var.dns_zone
      dns_subdomain        = var.dns_subdomain
    }
  )

  root_block_device {
    encrypted = true
    volume_size = 30
  }

  volume_tags = {
    Name = "traccar"
  }

  tags = {
    Name = "traccar"
  }
}
