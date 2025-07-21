# Projet NocoDB - Déploiement AWS & CI/CD

Ce dossier présente le déploiement complet de NocoDB sur AWS, illustrant :
- **Infrastructure** : Terraform (VPC, sous‑réseaux, RDS PostgreSQL, ECR, ECS Fargate, ALB, ACM, S3, autoscaling)
- **Conteneurisation** : Docker multi‑stage, `Dockerfile` & `start.sh`
- **CI/CD** : `.gitlab-ci.yml` (build, push, déploiement, tests de charge, destruction)
- **Tests de charge** : `locustfile.py` (100 utilisateurs, 2/sec, 30 s)
- **Monitoring** : CloudWatch + dashboards Grafana

> **NB** : Aucune clé ni secret n’est présent ici. Variables et accès sont configurés via GitLab CI variables ou AWS IAM roles.
