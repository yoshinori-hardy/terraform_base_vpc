# Global

variable "env" {
  default     = "production"
  description = "the environemnt we're working in"
}

#networking
variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-central-1"
}

variable "aws_az_a" {
  description = "the a-zone az"
  default     = "eu-central-1a"
}

variable "aws_az_b" {
  description = "the b-zone az"
  default     = "eu-central-1b"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "vpc_cidr" {
  description = "network address for the VPC"
  default     = "10.181.208.0/23"
}

variable "subnet-app-a" {
  description = "network address for the VPC"
  default     = "10.181.208.0/26"
}

variable "subnet-app-b" {
  description = "network address for the VPC"
  default     = "10.181.208.64/26"
}

variable "subnet-gw-a" {
  description = "network address for the VPC"
  default     = "10.181.209.128/28"
}

variable "subnet-gw-b" {
  description = "network address for the VPC"
  default     = "10.181.209.144/28"
}

variable "subnet-db-a" {
  description = "network address for the VPC"
  default     = "10.181.208.192/26"
}

variable "subnet-db-b" {
  description = "network address for the VPC"
  default     = "10.181.209.0/26"
}

#ssh key
variable "key_name" {
  default     = "test-app-frankfurt"
  description = "ssh key in use on the app tier"
}

#EC2
#variable "instance_type" {
#  default     = "t2.small"
#  description = "AWS instance type"
#}

variable "aws_ami" {
  default     = "ami-c28a48ad"
  description = "the daily built AMI"
}

#variable "asg_min" {
#  description = "Min numbers of servers in ASG"
#  default     = "2"
#}

#variable "asg_max" {
#  description = "Max numbers of servers in ASG"
#  default     = "4"
#}

#variable "asg_desired" {
#  description = "Desired numbers of servers in ASG"
#  default     = "2"
#}

#variable "aws_app_iam_profile" {
#  default     = "ccloud-preprod-iam-InstanceProfileTAXApplication-Q9OS5K3BLDLZ"
#  description = "Instance profile applied to app servers"
#}
