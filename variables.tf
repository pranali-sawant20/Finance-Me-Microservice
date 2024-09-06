variable "instance_type" {
  default = "t2.micro"
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 instances"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMaKktuuLiMqhMx+dlua5KGaV1X25CKjaCIVBCubacnz jenkins@ip-172-31-18-253"
}

variable "ssh_private_key" {
  description = "Path to the SSH private key file"
  type        = string
  default     = "/var/lib/jenkins/.ssh/id_ed25519"
}
