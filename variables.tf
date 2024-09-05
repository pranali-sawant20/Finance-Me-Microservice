variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "root_pass" {
  type    = string
  default = "ansible"
}

variable "instance_name" {
  type    = string
  default = "server"
}


variable "ssh_private_key" {
  type    = string
  default = "/home/ubuntu/.ssh/id_ed25519"
}
variable "ssh_public_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtYQcWryY8vYWfHQHLhirjquhMRQ9Xf1ONf8+0ydL4p ubuntu@ip-172-31-11-64"
}
