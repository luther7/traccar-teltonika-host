locals {
  five_years = 43830
}

resource "tls_private_key" "ca_private_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "local_file" "ca_key" {
  content         = tls_private_key.ca_private_key.private_key_pem
  filename        = "${path.module}/certificates/key.pem"
  file_permission = "0666"
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem       = tls_private_key.ca_private_key.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = local.five_years

  subject {
    common_name         = var.cert_common_name
    organization        = var.cert_organization
    organizational_unit = var.cert_organizational_unit
    country             = var.cert_country
  }

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "code_signing",
    "server_auth",
    "client_auth",
    "digital_signature",
    "key_encipherment",
  ]
}

resource "local_file" "ca_cert" {
  content         = tls_self_signed_cert.ca_cert.cert_pem
  filename        = "${path.module}/certificates/cert.pem"
  file_permission = "0666"
}
