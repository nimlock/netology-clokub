resource "aws_acm_certificate" "vpn_server_cert" {
  private_key = file("certs/server.key")
  certificate_body = file("certs/server.crt")
  certificate_chain = file("certs/ca.crt")
}

resource "aws_acm_certificate" "vpn_client_cert" {
  private_key = file("certs/client1.domain.tld.key")
  certificate_body = file("certs/client1.domain.tld.crt")
  certificate_chain = file("certs/ca.crt")
}

resource "aws_ec2_client_vpn_endpoint" "vpn-ep" {
  description            = "vpn-ep"
  server_certificate_arn = aws_acm_certificate.vpn_server_cert.arn
  client_cidr_block      = "10.0.0.0/22"
  split_tunnel = true

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.vpn_client_cert.arn
  }

  connection_log_options {
    enabled               = false
  }
}

resource "aws_security_group" "vpn_access" {
  vpc_id = aws_vpc.netology-vpc.id
  name = "vpn-netology-sg"

  ingress {
    from_port = 443
    protocol = "UDP"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "Incoming VPN connection"
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ec2_client_vpn_network_association" "vpn_subnets" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn-ep.id
  subnet_id = aws_subnet.private.id
  security_groups = [aws_security_group.vpn_access.id]
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn-ep.id
  target_network_cidr = aws_subnet.private.cidr_block
  authorize_all_groups = true
}
