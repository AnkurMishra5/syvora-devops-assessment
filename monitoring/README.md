# Monitoring Setup with Prometheus & Grafana

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Node.js App   │───▶│   Prometheus    │───▶│    Grafana      │
│   (Metrics)     │    │   (Scraping)    │    │  (Visualization)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Health Checks  │    │  Alert Manager  │    │   Dashboards    │
│   (K8s Probes)  │    │   (Alerting)    │    │   (Monitoring)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Components

### 1. Application Metrics
- **Health Endpoints**: `/health`, `/metrics`
- **Custom Metrics**: Request count, response time, error rates
- **Resource Metrics**: CPU, Memory, Network usage

### 2. Prometheus Setup
```bash
# Install Prometheus using Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

### 3. Grafana Dashboards
- **Node.js Application Dashboard**: Request metrics, error rates
- **Kubernetes Dashboard**: Pod status, resource usage
- **Infrastructure Dashboard**: Node metrics, cluster health

### 4. Alerting Rules
```yaml
# Example alerting rules
groups:
  - name: node-api-alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
      
      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Pod is crash looping"
```

### 5. Access URLs (Minikube)
```bash
# Get Grafana URL
minikube service prometheus-grafana -n monitoring --url

# Get Prometheus URL  
minikube service prometheus-kube-prometheus-prometheus -n monitoring --url

# Default Grafana credentials
# Username: admin
# Password: prom-operator
```

## Implementation Steps

1. **Deploy Prometheus Stack**
   ```bash
   kubectl create namespace monitoring
   helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
   ```

2. **Configure Service Monitor**
   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: ServiceMonitor
   metadata:
     name: node-api-monitor
   spec:
     selector:
       matchLabels:
         app.kubernetes.io/name: node-api
     endpoints:
     - port: http
       path: /metrics
   ```

3. **Import Dashboards**
   - Node.js Application Dashboard (ID: 11159)
   - Kubernetes Cluster Dashboard (ID: 7249)

4. **Set Up Alerts**
   - Configure AlertManager for Slack/Email notifications
   - Define SLIs/SLOs for the application
   - Set up runbooks for common issues

## Best Practices

- **Metrics Collection**: Use structured logging and metrics
- **Dashboard Design**: Focus on RED metrics (Rate, Errors, Duration)
- **Alerting**: Avoid alert fatigue with proper thresholds
- **Retention**: Configure appropriate data retention policies
- **Security**: Use RBAC and secure endpoints