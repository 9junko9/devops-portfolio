# Backend Terraform - S3

Ce dossier permet de créer un **bucket S3 versionné et chiffré** pour stocker l'état Terraform à distance.

## Ressources déployées

- Bucket S3 avec versioning (`my-nocodb-tf-state-secondjunko`)
- Chiffrement AES256
- Destruction autorisée (`force_destroy = true`)

##  Pourquoi ce backend ?

- Collaboration sans conflit sur les fichiers `.tfstate`
- Suivi de version et restauration possible
- Sécurité grâce au chiffrement côté serveur

##  Commandes utiles

```bash
terraform init
terraform apply -auto-approve
terraform destroy -auto-approve
