variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

## EC2 Instance Variables ---------------------------------------
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
}

variable "public_instance_count" {
  description = "Number of public instances to create"
  type        = number
}

## Networking Variables -------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}
