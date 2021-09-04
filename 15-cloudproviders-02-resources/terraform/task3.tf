resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.netology-sg.id
}

data "template_file" "bootstrap" {
  template = "${file("bootstrap.tmpl")}"
  vars = {
    url = data.aws_s3_bucket.b.bucket_domain_name
    file = data.aws_s3_bucket_object.img.key
  }
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "netology-lc-"
  image_id      = data.aws_ami.amazon-linux.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.netology-sg.id]
  user_data = data.template_file.bootstrap.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "netology-elb" {
  name               = "netology-elb"
  subnets = [aws_subnet.public.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 15
  }

  security_groups = [aws_security_group.netology-sg.id]

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "netology-elb"
  }
}

output "classic-balancer-dns_name" {
  value = "${aws_elb.netology-elb.dns_name}"
}

resource "aws_autoscaling_group" "netology-asg" {
  name                 = "netology-asg"
  launch_configuration = aws_launch_configuration.as_conf.name
  min_size             = 3
  max_size             = 6

  vpc_zone_identifier  = [aws_subnet.public.id]

  load_balancers = [aws_elb.netology-elb.id]

  lifecycle {
    create_before_destroy = true
  }
}
