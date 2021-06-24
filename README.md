# Knative Monitoring

This repository contains Grafana Dashboards and Prometheus Scraping configurations to monitor Knative.

It has been tested with the following configuration:
- k8s 1.19
- Istio 1.9
- kube-prometheus-stack v16.9 https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
- knative 0.23

Also, kube-state-metrics < v2.1 doesn't export all labels by default which means you must pass the following argument to kube-state-metrics:

```
- --metric-labels-allowlist=pods=[*],deployments=[app.kubernetes.io/name,app.kubernetes.io/component,app.kubernetes.io/instance]
```
Once kube-state-metrics has been adjusted, you will need to deploy the following servicemonitors and import the dashboards in the grafana folder.

```
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    app: controller
  name: controller
  namespace: knative-serving
spec:
  endpoints:
  - interval: 30s
    port: http-metrics
  namespaceSelector:
    matchNames:
    - knative-serving
  selector:
    matchLabels:
      app: controller
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    app: autoscaler
  name: autoscaler
  namespace: knative-serving
spec:
  endpoints:
  - interval: 30s
    port: http-metrics
  namespaceSelector:
    matchNames:
    - knative-serving
  selector:
    matchLabels:
      app: autoscaler
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    app: activator
  name: activator
  namespace: knative-serving
spec:
  endpoints:
  - interval: 30s
    port: http-metrics
  namespaceSelector:
    matchNames:
    - knative-serving
  selector:
    matchLabels:
      app: activator
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    app: webhook
  name: webhook
  namespace: knative-serving
spec:
  endpoints:
  - interval: 30s
    port: http-metrics
  namespaceSelector:
    matchNames:
    - knative-serving
  selector:
    matchLabels:
      app: activator
---
```