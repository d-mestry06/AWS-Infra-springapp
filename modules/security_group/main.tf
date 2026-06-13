# Security group for the Application Load Balancer (internet-facing)
resource "aws_security_group" "alb_security_group" {
  name        = "alb-security-group"
  description = "Allow HTTP/HTTPS inbound from the internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
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
    Name = "alb-security-group"
  }
}

# FIX: Separate security group for EC2 instances in the ASG.
# Previously the ASG launch template reused alb_security_group_id for EC2,
# which is wrong — EC2 should only accept port 80 FROM the ALB, not from 0.0.0.0/0.
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-security-group"
  description = "Allow port 80 only from the ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-security-group"
  }
}
