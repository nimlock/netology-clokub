resource "aws_vpc" "netology-vpc" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Name = "netology-vpc"
  }
}

resource "aws_security_group" "netology-sg" {
  name   = "netology-sg"
  vpc_id = aws_vpc.netology-vpc.id

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.netology-sg.id
}

resource "aws_security_group_rule" "icmp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.netology-sg.id
}
