terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0" # optionnel, si tu en as besoin explicitement
    }
  }
}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes = {
    config_path = pathexpand("~/.kube/config")
    # tu peux aussi ajouter config_context = "ton-contexte" si nécessaire
  }
}
