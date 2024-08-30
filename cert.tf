resource "tls_private_key" "teltonika_mtls_private_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "teltonika_mtls_cert" {
  private_key_pem       = tls_private_key.teltonika_mtls_private_key.private_key_pem
  validity_period_hours = 87600
  dns_names             = [var.cert_common_name]
  allowed_uses          = ["client_auth"]
}

resource "local_file" "teltonika_mtls_private_key" {
  content  = tls_private_key.teltonika_mtls_private_key.private_key_pem
  filename = "stunnel/cert/key.pem"
}

resource "local_file" "teltonika_mtls_cert" {
  content  = tls_self_signed_cert.teltonika_mtls_cert.cert_pem
  filename = "stunnel/cert/cert.pem"
}
