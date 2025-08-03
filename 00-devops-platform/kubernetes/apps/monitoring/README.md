# Monitoring

## Ce que ça déploie
- Prometheus (kube-prometheus-stack)
- Grafana
- Loki + Promtail

## Déploiement
L’application ArgoCD `monitoring` est définie dans ce dossier.  
Après push :
```sh
kubectl -n argocd patch application monitoring --type=merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
