variable "cidr" {
  description = "CIDR du VPC"
  type        = string
}

variable "public_subnets" {
  description = "Liste des CIDR pour les subnets publics"
  type        = list(string)
}
