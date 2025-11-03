#!/bin/bash

# Syvora DevOps Assessment - Deployment Script
set -e

echo "🚀 Starting Syvora DevOps Assessment Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if minikube is running
    if ! minikube status > /dev/null 2>&1; then
        print_error "Minikube is not running. Please start minikube first:"
        echo "minikube start"
        exit 1
    fi
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    # Check if helm is available
    if ! command -v helm &> /dev/null; then
        print_error "helm is not installed or not in PATH"
        exit 1
    fi
    
    # Check if terraform is available
    if ! command -v terraform &> /dev/null; then
        print_error "terraform is not installed or not in PATH"
        exit 1
    fi
    
    print_status "All prerequisites met ✅"
}

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    print_status "Deploying infrastructure with Terraform..."
    
    cd terraform
    terraform init
    terraform plan
    terraform apply -auto-approve
    cd ..
    
    print_status "Infrastructure deployed ✅"
}

# Deploy application with Helm
deploy_application() {
    print_status "Deploying application with Helm..."
    
    # Update Helm dependencies
    helm dependency update helm/node-api
    
    # Deploy the application
    helm upgrade --install node-api helm/node-api \
        --namespace devops-app \
        --create-namespace \
        --wait \
        --timeout 300s
    
    print_status "Application deployed ✅"
}

# Deploy monitoring stack
deploy_monitoring() {
    print_status "Deploying monitoring stack..."
    
    # Add Prometheus Helm repository
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Install Prometheus stack
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace \
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
        --wait \
        --timeout 600s
    
    print_status "Monitoring stack deployed ✅"
}

# Get access information
get_access_info() {
    print_status "Getting access information..."
    
    echo ""
    echo "🌐 Access Information:"
    echo "===================="
    
    # Get application URL
    NODE_PORT=$(kubectl get svc node-api -n devops-app -o jsonpath='{.spec.ports[0].nodePort}')
    MINIKUBE_IP=$(minikube ip)
    echo "📱 Application URL: http://$MINIKUBE_IP:$NODE_PORT"
    echo "   Available endpoints: /users, /messages, /users/1, /messages/1"
    
    # Get Grafana URL
    echo "📊 Grafana URL: Run 'minikube service prometheus-grafana -n monitoring --url'"
    echo "   Default credentials: admin / prom-operator"
    
    # Get Prometheus URL
    echo "🔍 Prometheus URL: Run 'minikube service prometheus-kube-prometheus-prometheus -n monitoring --url'"
    
    echo ""
    echo "📋 Useful Commands:"
    echo "==================="
    echo "kubectl get pods -n devops-app"
    echo "kubectl logs -f deployment/node-api -n devops-app"
    echo "kubectl get svc -n devops-app"
    echo "helm list -n devops-app"
    echo ""
}

# Main deployment function
main() {
    print_status "🎯 Syvora DevOps Assessment - Complete Deployment"
    echo ""
    
    check_prerequisites
    deploy_infrastructure
    deploy_application
    deploy_monitoring
    get_access_info
    
    print_status "🎉 Deployment completed successfully!"
    print_warning "Don't forget to update the Docker Hub username in helm/node-api/values.yaml"
}

# Run main function
main "$@"