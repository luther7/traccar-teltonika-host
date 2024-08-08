variable "dns_zone" {
  type = string
}

variable "dns_subdomain" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

variable "tailscale_tags" {
  type = list(string)
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}
