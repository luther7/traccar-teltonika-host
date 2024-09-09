resource "local_file" "certificates_kube_secret" {
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
  filename        = "${path.module}/../out/kube/certificates-secret.yaml"
  file_permission = "0666"
}

resource "local_file" "ddclient_kube_secret" {
  content = (yamlencode({
    "apiVersion" : "v1"
    "kind" : "Secret"
    "metadata" : {
      "name" : "ddclient"
    }
    "data" : {
      "protocol": base64encode(var.ddclient_protocol)
      "user": base64encode(var.ddclient_user)
      "password": base64encode(var.ddclient_password)
      "zone": base64encode(var.ddclient_zone)
      "host": base64encode(var.ddclient_host)
    }
  }))
  filename        = "${path.module}/../out/kube/ddclient-secret.yaml"
  file_permission = "0666"
}
