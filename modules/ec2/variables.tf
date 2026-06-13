variable "vpc_id" {
  description = "The ID of the VPC where the EC2 instances will be launched."
  type        = string
}

variable "region" {
  description = "The AWS region where resources are deployed."
  type        = string
}

variable "private_subnet_az1_id" {}

variable "private_subnet_az2_id" {}