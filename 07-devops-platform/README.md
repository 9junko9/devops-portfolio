# 🛠️ DevOps Platform – GitOps-ready Self-hosted Stack on AWS

Projet personnel DevOps 
L’objectif est de reproduire une plateforme DevOps moderne, **auto-hébergée**, **GitOps-ready**, et entièrement automatisée avec **Terraform**, **Ansible**, et **Kubernetes**.


## 🎯 Objectif

Concevoir et déployer une stack DevOps complète où :

- L'infrastructure est provisionnée avec **Terraform** sur **AWS**
- Les machines sont configurées automatiquement avec **Ansible**
- Les services sont déployés sur **Kubernetes** (via EKS)
- Le déploiement applicatif est géré avec **ArgoCD (GitOps)**
- La documentation est centralisée dans **Outline**
- Le code est hébergé dans une instance auto-hébergée de **Forgejo**
- Le monitoring est assuré par **Prometheus + Grafana**, et les logs via **Loki**


## 🧱 Stack utilisée

| Composant     | Outil utilisé                  |
|---------------|--------------------------------|
| GitOps        | ArgoCD                         |
| Git           | Forgejo (self-hosted Git)      |
| Documentation | Outline                        |
| Monitoring    | Prometheus + Grafana           |
| Logging       | Loki                           |
| Secrets       | SOPS ou Sealed Secrets         |
| CI/CD         | GitHub Actions (optionnel)     |
| Infra         | Terraform                      |
| Config Serveurs | Ansible                      |
| Conteneurs    | Kubernetes (EKS) + Helm        |
| Sécurité      | HTTPS, RBAC, IAM AWS           |


## 📂 Arborescence du projet

```bash
devops-platform/
├── terraform/      # Infrastructure AWS (VPC, EKS, IAM, etc.)
├── ansible/        # Configuration des serveurs (Docker, Kubeadm…)
├── kubernetes/     # Manifests K8s, Helm charts, ArgoCD apps
├── bootstrap/      # Script de provision et enchaînement Terraform + Ansible
├── .gitignore
├── README.md
