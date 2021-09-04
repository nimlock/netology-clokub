resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.netology-vpc.id
  cidr_block = "172.31.32.0/19"
  availability_zone = "us-west-1c"
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
