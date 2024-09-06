variable "instance_type" {
  default = "t2.micro"
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 instances"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJ0aLiohOZKlY2atZHQPT/vIU9wcCDjft3CR4G4sWSW jenkins@ip-172-31-29-33"
}

variable "ssh_private_key" {
  description = "Path to the SSH private key file"
  type        = string
  default     = "/var/lib/jenkins/.ssh/id_ed25519"
}
