variable "ssh_key_name" {
  type = string
}

variable "cert_common_name" {
  type = string
}

variable "tailscale_authkey" {
  type      = string
  sensitive = true
}
