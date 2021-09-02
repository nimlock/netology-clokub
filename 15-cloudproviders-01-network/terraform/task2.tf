resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.netology-vpc.id
  cidr_block = "172.31.32.0/19"
  availability_zone = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}

resource "aws_internet_gateway" "netology-gw" {
  vpc_id = aws_vpc.netology-vpc.id

  tags = {
    Name = "netology-gw"
  }
}

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.netology-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.netology-gw.id
    }

  tags = {
    Name = "public-route"
  }
}

resource "aws_route_table_association" "netology-rtassoc1" {
     subnet_id      = aws_subnet.public.id
     route_table_id = aws_route_table.public-route.id
}

resource "aws_key_pair" "vm1-key" {
  key_name   = "vm1-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9YYUH7NOHclUCeKsnLvh6D/pylINb56GEZ16b6AsWcp+D9WFg5mkO26wdPHNaUZWrzamZAhhF0UXtqsQn98ebwQRnX7Ox5OAntLnHk5Q/n4CS2yFH9mvQ9/0aAvLKHb2Wc2ZyLPfwwUMNUQR6go8w301OxGaTM9GzeLGOX6P9AkUKYeAWmwJ9WE4dPgm8nhgk1SwpREU8IioKiWdL8XNLMoODFl7o+N2FgGl39cZaIMWN5XmZl1hzs4BfXLUTSYzR3BZsgygXjucdUPHvfDKCotjudmOnm330d4VDivXYSdPJmJuXJGiqFiI4PKyLerFuSkBEV0ExRmXmuH6alodcFIXo979i6FAAI4GjwuihA4hZKGjMPZIGzx2ojCpPfDj9E+e0D8NMKAt5DTPjdgXY0NSByDGEyf8JBPVWA6csIWeuwTGsI/bw0xAJOH5wfU/eiuz5pjd2zga6ZDFUDK3cvJ7uYehg5xPbc2xX/TZch6OVOFk6B8MoxYyf7+EBuw8= ivan@kubang"
}

resource "aws_instance" "vm1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name  = aws_key_pair.vm1-key.key_name
  count = 1

  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true
  security_groups = [ aws_security_group.netology-sg.id ]

  tags = {
    Name = "vm1"
  }

  # lifecycle {
  #   create_before_destroy = true
  # }
}
