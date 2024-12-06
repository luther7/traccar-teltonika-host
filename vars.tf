variable "aws_tags" {
  type = map(any)
  default = {
    Name = "traccar"
  }
}

variable "aws_ami" {
  type = string
  # Ubuntu 24.04 arm64 ap-southeast-2
  default = "ami-0e86a390303d8b431"
}

variable "aws_instance_type" {
  type    = string
  default = "t4g.nano"
}

variable "aws_availability_zone" {
  type    = string
  default = "ap-southeast-2a"
}

variable "aws_root_volume_size" {
  type    = number
  default = 8
}

variable "aws_storage_volume_size" {
  type    = number
  default = 16
}

variable "aws_ssh_key_name" {
  type = string
}

variable "tailscale_tags" {
  type = list(string)
}

variable "tailscale_hostname" {
  type    = string
  default = "traccar"
}

variable "cert_common_name" {
  type = string
}

variable "cert_organization" {
  type = string
}

variable "cert_organizational_unit" {
  type = string
}

variable "cert_country" {
  type = string
}

variable "ddclient_protocol" {
  type = string
}

variable "ddclient_user" {
  type = string
}

variable "ddclient_password" {
  type      = string
  sensitive = true
}

variable "ddclient_zone" {
  type = string
}

variable "ddclient_host" {
  type = string
}
