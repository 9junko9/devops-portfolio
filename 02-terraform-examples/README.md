# Exemples Terraform

Ce dossier contient des extraits de configurations Terraform pour illustrer la gestion d’infrastructure as code sur AWS :

- `main.tf`                  : configuration du provider AWS et appel du module réseau  
- `variables.tf`             : déclaration des variables réutilisables (région AWS, AMI, clé SSH)  
- `s3-versioning.tf`         : création d’un bucket S3 versionné et chiffré via des ressources dédiées  
- `ec2-basic.tf`             : déploiement d’une instance EC2 accessible en SSH  
- `modules/network/`         : module personnalisable pour déployer un VPC et des subnets publics  
