#!/bin/bash

# Syvora DevOps Assessment - Setup Verification Script
set -e

echo "🔍 Verifying Syvora DevOps Assessment Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0

# Function to print test results
test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC}: $2"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}: $2"
        ((FAILED++))
    fi
}

echo ""
echo "🔧 Checking Prerequisites..."
echo "=========================="

# Check Docker
docker --version > /dev/null 2>&1
test_result $? "Docker is installed"

# Check Docker Compose
docker-compose --version > /dev/null 2>&1
test_result $? "Docker Compose is installed"

# Check Minikube
minikube version > /dev/null 2>&1
test_result $? "Minikube is installed"

# Check if Minikube is running
minikube status > /dev/null 2>&1
test_result $? "Minikube is running"

# Check kubectl
kubectl version --client > /dev/null 2>&1
test_result $? "kubectl is installed"

# Check Helm
helm version > /dev/null 2>&1
test_result $? "Helm is installed"

# Check Terraform
terraform version > /dev/null 2>&1
test_result $? "Terraform is installed"

echo ""
echo "📁 Checking Project Structure..."
echo "==============================="

# Check Dockerfile
[ -f "Dockerfile" ]
test_result $? "Dockerfile exists"

# Check docker-compose.yml
[ -f "docker-compose.yml" ]
test_result $? "docker-compose.yml exists"

# Check GitHub Actions workflow
[ -f ".github/workflows/docker-build.yml" ]
test_result $? "GitHub Actions workflow exists"

# Check Terraform files
[ -f "terraform/main.tf" ]
test_result $? "Terraform configuration exists"

# Check Helm chart
[ -f "helm/node-api/Chart.yaml" ]
test_result $? "Helm Chart.yaml exists"

[ -f "helm/node-api/values.yaml" ]
test_result $? "Helm values.yaml exists"

[ -f "helm/node-api/templates/deployment.yaml" ]
test_result $? "Helm deployment template exists"

[ -f "helm/node-api/templates/service.yaml" ]
test_result $? "Helm service template exists"

# Check Node.js application
[ -f "node-express-server-rest-api/package.json" ]
test_result $? "Node.js application package.json exists"

echo ""
echo "🐳 Testing Docker Build..."
echo "========================="

# Test Docker build
docker build -t test-node-api . > /dev/null 2>&1
test_result $? "Docker image builds successfully"

# Clean up test image
docker rmi test-node-api > /dev/null 2>&1

echo ""
echo "☸️  Testing Kubernetes Connection..."
echo "==================================="

# Test kubectl connection
kubectl cluster-info > /dev/null 2>&1
test_result $? "kubectl can connect to cluster"

# Check if required namespaces exist or can be created
kubectl get namespace devops-app > /dev/null 2>&1 || kubectl create namespace devops-app > /dev/null 2>&1
test_result $? "devops-app namespace is available"

kubectl get namespace monitoring > /dev/null 2>&1 || kubectl create namespace monitoring > /dev/null 2>&1
test_result $? "monitoring namespace is available"

echo ""
echo "⚙️  Testing Terraform..."
echo "======================"

cd terraform
terraform init > /dev/null 2>&1
test_result $? "Terraform initializes successfully"

terraform validate > /dev/null 2>&1
test_result $? "Terraform configuration is valid"
cd ..

echo ""
echo "⛵ Testing Helm Chart..."
echo "======================"

# Lint Helm chart
helm lint helm/node-api > /dev/null 2>&1
test_result $? "Helm chart passes linting"

# Test Helm template rendering
helm template test-release helm/node-api > /dev/null 2>&1
test_result $? "Helm templates render successfully"

echo ""
echo "📊 Summary"
echo "=========="
echo -e "Tests Passed: ${GREEN}$PASSED${NC}"
echo -e "Tests Failed: ${RED}$FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All checks passed! Your setup is ready for deployment.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Update Docker Hub username in helm/node-api/values.yaml"
    echo "2. Set up GitHub secrets (DOCKERHUB_USERNAME, DOCKERHUB_TOKEN)"
    echo "3. Run ./scripts/deploy.sh to deploy everything"
    exit 0
else
    echo -e "\n${RED}❌ Some checks failed. Please fix the issues above before proceeding.${NC}"
    exit 1
fi