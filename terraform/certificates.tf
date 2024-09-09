locals {
  five_years = 43830
}

resource "tls_private_key" "ca_private_key" {
  algorithm   = "RSA"
  rsa_bits    = 4096
  ecdsa_curve = "P384"
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
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "ca_cert" {
  content         = tls_self_signed_cert.ca_cert.cert_pem
  filename        = "${path.module}/../certificates/ca-certificate.pem"
  file_permission = "0666"
}

resource "local_file" "ca_key" {
  content         = tls_private_key.ca_private_key.private_key_pem
  filename        = "${path.module}/../certificates/ca-private-key.pem"
  file_permission = "0666"
}

resource "local_file" "kube_secret" {
  content = (yamlencode({
    "apiVersion" : "v1"
    "kind" : "Secret"
    "metadata" : {
      "name" : "certificates"
    }
    "data" : {
      "ca-certificate.pem" : base64encode(tls_self_signed_cert.ca_cert.cert_pem)
      "ca-private-key.pem" : base64encode(tls_private_key.ca_private_key.private_key_pem)
    }
  }))
  filename        = "${path.module}/../certificates/certificates.yaml"
  file_permission = "0666"
}
