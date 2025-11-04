# Node.js Express REST API - DevOps Assessment

This project containerizes and deploys a Node.js Express REST API using Docker, Kubernetes, and modern DevOps practices.

## Application

The application is a simple REST API built with Node.js and Express, providing endpoints for users and messages.

### API Endpoints
- `GET /users` - List all users
- `GET /users/:id` - Get specific user
- `GET /messages` - List all messages  
- `GET /messages/:id` - Get specific message
- `POST /messages` - Create new message

## Docker Setup

### Build and Run Locally
```bash
docker-compose up --build
```

The application will be available at `http://localhost:3000`

### Manual Docker Commands
```bash
# Build image
docker build -t ankdoc1/syvora-node-api:latest .

# Run container
docker run -p 3000:3000 ankdoc1/syvora-node-api:latest
```

## CI/CD Pipeline

GitHub Actions workflow automatically:
- Builds Docker image on push to main branch
- Pushes image to Docker Hub

### Required GitHub Secrets
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

## Kubernetes Deployment

### Infrastructure (Terraform)
```bash
cd terraform
terraform init
terraform apply
```

### Application Deployment (Helm)
```bash
helm install node-api helm/node-api --namespace devops-app --create-namespace
```

### Access Application
```bash
kubectl get svc -n devops-app
# Application available on NodePort 30080
```

## Monitoring

For production monitoring, deploy Prometheus and Grafana:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
```

## Local Development

1. Install dependencies: `npm install`
2. Start application: `npm start`
3. Test endpoints: `curl http://localhost:3000/users`

## Project Structure

- `Dockerfile` - Container definition
- `docker-compose.yml` - Local development setup
- `.github/workflows/` - CI/CD pipeline
- `terraform/` - Infrastructure as code
- `helm/node-api/` - Kubernetes deployment charts
- `node-express-server-rest-api/` - Application source code