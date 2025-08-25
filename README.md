# Knative Monitoring

This repository contains Grafana Dashboards and Prometheus Scraping configurations to monitor Knative.

It has been tested with the following configuration:
- Knative v1.19 (https://knative.dev)
- Kubernetes 1.32 ([kind](https://kind.sigs.k8s.io/))
- kube-prometheus-stack 76.5.0 https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

Also, `kube-state-metrics` doesn't export all labels by default which means you must pass the following argument:

```
- --metric-labels-allowlist=pods=[*],deployments=[app.kubernetes.io/name,app.kubernetes.io/component,app.kubernetes.io/instance]
```

Once `kube-state-metrics` has been adjusted, you will need to deploy the following servicemonitors and import the dashboards in the [grafana](/grafana) folder.

```
kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/monitoring/main/config/serving-monitors.yaml
kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/monitoring/main/config/eventing-monitors.yaml
```

This repo uses the jsonnet config language to make things configurable. Visit https://github.com/google/jsonnet to install the CLI.


This repository takes influence from:

Istio Dashboards: https://github.com/istio/istio/tree/release-1.27/manifests/addons/dashboards/lib
Grafana Controller Runtime Example: https://github.com/grafana/grafonnet/blob/5a8f3d6aa89b7e7513528371d2d1265aedc844bc/examples/runtimeDashboard/queries.libsonnet
OTel Collector Dashboards: https://github.com/monitoringartist/opentelemetry-collector-monitoring/blob/main/dashboard/opentelemetry-collector-dashboard.json
