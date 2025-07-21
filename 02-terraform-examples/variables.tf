variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-3"
}

variable "instance_ami" {
  description = "AMI pour EC2"
  type        = string
  default     = "ami-0abcdef1234567890"
}

variable "ssh_key_name" {
  description = "Nom de la clé SSH"
  type        = string
}
