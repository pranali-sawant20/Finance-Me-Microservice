variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "The type of EC2 instance to use"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the SSH key pair to use for access"
  type        = string
  default     = "key02"
}

variable "ssh_private_key" {
  description = "The private key for SSH access"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "ssh_public_key" {
  description = "The public key for SSH access"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ami_id" {
  description = "The ID of the AMI to use for the instance"
  type        = string
  default     = "ami-0522ab6e1ddcc7055"
}
