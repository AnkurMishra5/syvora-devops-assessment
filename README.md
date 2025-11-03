# Syvora DevOps Technical Assessment

## 🧩 Overview

This project demonstrates a complete DevOps pipeline for deploying a Node.js Express REST API using modern DevOps practices and tools.

## 🏗️ Architecture & Tech Stack

| Component          | Tool/Technology      | Tier    |
| ------------------ | -------------------- | ------- |
| **CI/CD**          | GitHub Actions       | ✅ Free |
| **Image Registry** | Docker Hub           | ✅ Free |
| **Cluster**        | Minikube (local)     | ✅ Free |
| **IaC**            | Terraform (local)    | ✅ Free |
| **Deploy**         | Helm                 | ✅ Free |
| **Monitoring**     | Prometheus + Grafana | ✅ Free |

## 📋 Requirements Checklist

- ✅ **Dockerfile and docker-compose** for the Node.js application
- ✅ **CI/CD Pipeline** with GitHub Actions (builds on main branch)
- ✅ **Docker Hub Integration** (pushes images via CI)
- ✅ **Kubernetes Cluster** setup with Terraform
- ✅ **Helm Charts** for application deployment
- ✅ **Monitoring & Logging** architecture documentation

---

## 🚀 Quick Start

### Prerequisites

```bash
# Required tools
- Docker & Docker Compose
- Minikube
- kubectl
- Helm 3.x
- Terraform
- Git
```

### 1. Clone and Setup

```bash
git clone <your-repo>
cd syvora-devops-assessment

# Start Minikube
minikube start --driver=docker --memory=4096 --cpus=2
```

### 2. Configure Docker Hub

Update your Docker Hub username in:

- `helm/node-api/values.yaml` (line 4)
- Set GitHub secrets: `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`

### 3. Deploy Everything

```bash
# Make script executable
chmod +x scripts/deploy.sh

# Run complete deployment
./scripts/deploy.sh
```

---

## 🐳 Docker

### Local Development

```bash
# Build and run locally
docker-compose up --build

# Test the API
curl http://localhost:3000/users
curl http://localhost:3000/messages
```

### Manual Docker Build

```bash
# Build image
docker build -t your-username/node-express-api:latest .

# Run container
docker run -p 4000:4000 your-username/node-express-api:latest
```

---

## ⚙️ CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/docker-build.yml`) automatically:

1. **Triggers** on push to `main` branch
2. **Builds** Docker image from the Node.js application
3. **Pushes** to Docker Hub with `latest` tag
4. **Uses** GitHub Secrets for Docker Hub authentication

### Setup GitHub Secrets

```bash
# Required secrets in GitHub repository settings:
DOCKERHUB_USERNAME=your-dockerhub-username
DOCKERHUB_TOKEN=your-dockerhub-access-token
```

---

## 🏗️ Infrastructure (Terraform)

### Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### What it creates:

- `devops-app` namespace for the application
- `monitoring` namespace for Prometheus/Grafana
- Kubernetes provider configuration for Minikube

---

## ⛵ Kubernetes Deployment (Helm)

### Deploy Application

```bash
# Install/upgrade the application
helm upgrade --install node-api helm/node-api \
  --namespace devops-app \
  --create-namespace

# Check deployment
kubectl get pods -n devops-app
kubectl get svc -n devops-app
```

### Helm Chart Features:

- **Deployment** with 2 replicas
- **Service** (NodePort on 30080)
- **Health Checks** (liveness & readiness probes)
- **Resource Limits** (CPU: 500m, Memory: 512Mi)
- **Configurable** via values.yaml

---

## 📊 Monitoring & Logging

### Architecture

```
Node.js App → Prometheus → Grafana
     ↓             ↓          ↓
Health Checks  AlertManager  Dashboards
```

### Deploy Monitoring Stack

```bash
# Add Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Install Prometheus + Grafana
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

### Access Monitoring

```bash
# Grafana (admin/prom-operator)
minikube service prometheus-grafana -n monitoring --url

# Prometheus
minikube service prometheus-kube-prometheus-prometheus -n monitoring --url
```

### Key Metrics to Monitor:

- **Application**: Request rate, error rate, response time
- **Infrastructure**: CPU, memory, disk usage
- **Kubernetes**: Pod status, deployments, services

---

## 🔧 Useful Commands

### Application Management

```bash
# View application logs
kubectl logs -f deployment/node-api -n devops-app

# Scale application
kubectl scale deployment node-api --replicas=3 -n devops-app

# Port forward for local access
kubectl port-forward svc/node-api 3000:3000 -n devops-app
```

### Troubleshooting

```bash
# Check pod status
kubectl get pods -n devops-app -o wide

# Describe pod for issues
kubectl describe pod <pod-name> -n devops-app

# Check events
kubectl get events -n devops-app --sort-by='.lastTimestamp'
```

### Helm Operations

```bash
# List releases
helm list -n devops-app

# Rollback deployment
helm rollback node-api 1 -n devops-app

# Uninstall
helm uninstall node-api -n devops-app
```

---

## 🌐 Access Information

After successful deployment:

- **Application**: `http://<minikube-ip>:30080`
- **Grafana**: Use `minikube service prometheus-grafana -n monitoring --url`
- **Prometheus**: Use `minikube service prometheus-kube-prometheus-prometheus -n monitoring --url`

Get Minikube IP: `minikube ip`

---

## 🔒 Security Considerations

- **Image Security**: Use specific tags instead of `latest` in production
- **Secrets Management**: Use Kubernetes secrets for sensitive data
- **RBAC**: Implement proper role-based access control
- **Network Policies**: Restrict pod-to-pod communication
- **Resource Limits**: Prevent resource exhaustion

---

## 📈 Production Readiness

### Improvements for Production:

1. **Multi-environment** setup (dev/staging/prod)
2. **GitOps** workflow with ArgoCD
3. **External secrets** management (Vault/AWS Secrets Manager)
4. **Ingress controller** with SSL/TLS
5. **Horizontal Pod Autoscaler** (HPA)
6. **Persistent storage** for stateful components
7. **Backup and disaster recovery** procedures

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Submit a pull request

---

## 📝 Notes

- This setup is optimized for **local development** and **demonstration**
- For production use, consider managed Kubernetes services (EKS, GKE, AKS)
- Monitoring setup includes basic dashboards - customize based on requirements
- CI/CD pipeline can be extended with testing, security scanning, and deployment stages

---

**Author**: Syvora DevOps Assessment  
**Date**: November 2025  
**Version**: 1.0
