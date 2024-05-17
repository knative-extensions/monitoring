# Knative Monitoring
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fknative-extensions%2Fmonitoring.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fknative-extensions%2Fmonitoring?ref=badge_shield)


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
Once kube-state-metrics has been adjusted, you will need to deploy the following servicemonitors and import the dashboards in the [grafana](/grafana) folder.

```
kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/monitoring/main/servicemonitor.yaml
```

## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fknative-extensions%2Fmonitoring.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fknative-extensions%2Fmonitoring?ref=badge_large)