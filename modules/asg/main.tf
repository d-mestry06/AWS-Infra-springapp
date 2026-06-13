data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Strip the ":3306" port suffix from the RDS endpoint.
# application.properties appends :3306 itself, so DB_ENDPOINT must be hostname only.
locals {
  rds_host = split(":", var.rds_db_endpoint)[0]
}

resource "aws_launch_template" "ec2_asg" {
  name          = "my-launch-template"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.iam_ec2_instance_profile.name
  }

  # FIX: pass db_endpoint (hostname only) — matches the ${db_endpoint} var in userdata.sh
  user_data = base64encode(templatefile("${path.root}/userdata.sh", {
    db_endpoint = local.rds_host
  }))

  vpc_security_group_ids = [var.ec2_security_group_id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg-tf" {
  name              = "${var.project_name}-ASG"
  desired_capacity  = 1
  max_size          = 1
  min_size          = 1
  force_delete      = true
  depends_on        = [var.application_load_balancer]
  target_group_arns = [var.alb_target_group_arn]
  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.ec2_asg.id
    version = aws_launch_template.ec2_asg.latest_version
  }

  vpc_zone_identifier = [var.private_subnet_az1_id, var.private_subnet_az2_id]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ASG"
    propagate_at_launch = true
  }
}
