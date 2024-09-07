variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to use"
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key pair to use for access"
  type        = string
}

variable "ssh_private_key" {
  description = "The private key for SSH access"
  type        = string
}

variable "ssh_public_key" {
  description = "The public key for SSH access"
  type        = string
}

variable "ami_id" {
  description = "The ID of the AMI to use for the instance"
  type        = string
}
