data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
#creating apache
resource "aws_instance" "apache" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  key_name = "server"

  subnet_id = aws_subnet.private[0].id

  vpc_security_group_ids = [aws_security_group.apache_sg.id]
  user_data = file("script.sh")


  tags = {
    Name = "apache"
  }
}
#creating bastion
resource "aws_instance" "bastion" {
  ami        = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  key_name = "server"

  subnet_id = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion"
  }
}

#creating target group

resource "aws_lb_target_group" "apache_tg" {

  name     = "apache-tg"
  port     = 80
  protocol = "HTTP"

  vpc_id = aws_vpc.my_vpc.id

  health_check {
    path = "/"

    port = "traffic-port"
  }

  tags = {
    Name = "apache-target-group"
  }
}

#atatching target group
resource "aws_lb_target_group_attachment" "apache_attach" {

  target_group_arn = aws_lb_target_group.apache_tg.arn

  target_id = aws_instance.apache.id

  port = 80
}
#creating load balancer

resource "aws_lb" "alb" {

  name               = "apache-alb"

  internal           = false

  load_balancer_type = "application"

  security_groups = [
    aws_security_group.lb_sg.id
  ]

  subnets = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]

  tags = {
    Name = "Apache-ALB"
  }
}
#adding listener
resource "aws_lb_listener" "listener" {

  load_balancer_arn = aws_lb.alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.apache_tg.arn
  }
}

#creating grafana ec2
resource "aws_instance" "grafana" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  key_name = "server"

  subnet_id = aws_subnet.private[0].id

  vpc_security_group_ids = [aws_security_group.apache_sg.id]
  user_data = file("script.sh")


  tags = {
    Name = "grafana"
  }
}