# DevOps Portfolio - Jennifer Vernet

Bienvenue sur mon portfolio DevOps. Vous trouverez ici des projets concrets réalisés sur des environnements Linux et AWS, illustrant mes compétences en Infrastructure as Code, automatisation, CI/CD, monitoring, scripting et sécurité cloud.

## 🚀 Projet phare : [00-devops-platform](./00-devops-platform/)

**Plateforme DevOps GitOps-ready auto-hébergée sur AWS**

Déploiement complet d’une infrastructure cloud avec :

- Provisionnement AWS via Terraform (IAM, EC2, S3, Route53…)
- Configuration système avec Ansible (K3s, Prometheus, Grafana, ArgoCD…)
- Orchestration GitOps avec ArgoCD
- CI/CD auto-hébergée avec Drone CI
- Monitoring centralisé (Prometheus + Grafana), gestion de logs (Loki)
- Documentation collaborative (Outline), secrets chiffrés (SOPS)
- Architecture modulaire, versionnée, documentée

Ce projet démontre ma capacité à industrialiser une plateforme complète, depuis le provisioning jusqu’à la mise en production, selon les standards GitOps modernes.

## 📁 Projets supplémentaires

- [01-nocodb-aws-ecs](./01-nocodb-aws-ecs) : Déploiement complet d’une application NocoDB sur AWS via Terraform, ECS Fargate, RDS, ALB, S3, CloudWatch et pipeline GitLab CI/CD.

- [02-terraform-examples](./02-terraform-examples) : Extraits et modules Terraform (réseau, base de données, sécurité).

- [03-ansible-playbooks](./03-ansible-playbooks) : Playbooks Ansible (création d’utilisateurs, durcissement, installation de paquets…).

- [04-ci-cd-pipelines](./04-ci-cd-pipelines) : Pipelines GitLab CI avec jobs de build, test, déploiement, et déclenchement conditionnel.

- [05-monitoring](./05-monitoring) : Dashboards Prometheus/Grafana

- [06-scripts](./06-scripts) : Scripts Bash et Python (automatisation, tests de charge avec Locust, etc.)
