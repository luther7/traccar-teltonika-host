### AWS settings.
#
# The name of a preexisting AWS EC2 SSH key pair to register with the server. Please ensure that
# this key is added to your SSH agent.
aws_ssh_key_name = "TODO"

### Tailscale settings.
#
# Tailscale tags for the server. Tags may allow automatic access to the server.
# Reference: https://tailscale.com/kb/1068/tags
tailscale_tags = ["tag:TODO"]

### mTLS certificate settings.
#
# The cert common name. Set this to be the domain of the Traccar server.
cert_common_name = "TODO"
# The cert organization. The value is not important as the certificate is self-signed.
cert_organization = "TODO"
# The cert organizational unit. The value is not important as the certificate is self-signed.
cert_organizational_unit = "TODO"
# The cert country. The value is not important as the certificate is self-signed.
cert_country = "TODO"

### ddclient settings.
#
# Reference: https://ddclient.net/protocols.html
#
# The ddclient protocol e.g. 'cloudflare'.
ddclient_protocol = "TODO"
# The ddclient user e.g. the email of your Cloudflare account.
ddclient_user = "TODO"
# The ddclient password e.g. an API token for your Cloudflare account.
ddclient_password = "TODO"
# The ddclient zone. Set this to the zone name of the Traccar server's domain (the
# domain name and top-level domain). For example, if the Traccar server's domain is
# traccar.example.com, the zone is likely to be example.com.
ddclient_zone = "TODO"
# The ddclient host. Set this to the fully-qualified host name of the Traccar server (subdomain,
# domain name and top-level domain)
ddclient_host = "TODO"
