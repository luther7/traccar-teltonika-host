variable "ami" {
  type    = string
  default = "ami-0e86a390303d8b431"
}

variable "instance_type" {
  type    = string
  default = "t4g.micro"
}

variable "availability_zone" {
  type    = string
  default = "ap-southeast-2a"
}

variable "root_volume_size" {
  type    = number
  default = 8
}

variable "storage_volume_size" {
  type    = number
  default = 16
}

variable "ssh_key_name" {
  type = string
}

variable "tailscale_authkey" {
  type      = string
  sensitive = true
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
  type = string
  sensitive = true
}

variable "ddclient_zone" {
  type = string
}

variable "ddclient_host" {
  type = string
}
