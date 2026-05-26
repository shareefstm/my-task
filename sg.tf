#load balancer sg

resource "aws_security_group" "lb_sg" {
  name        = "load-balancer-sg"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "HTTP Access"

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lb-sg"
  }
}

#security group for bastion
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "SSH Access"

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["106.215.171.198/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_security_group" "apache_sg" {
  name        = "apache-sg"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "SSH Access"

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    security_groups = [aws_security_group.bastion_sg.id]
  }
 ingress {
    description = "HTTP Access"

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    security_groups   = [aws_security_group.lb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "apache-sg"
  }
}
