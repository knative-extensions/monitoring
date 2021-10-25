Import these dashboards to Grafana.

The steps are documented at https://grafana.com/docs/grafana/latest/dashboards/export-import/

If you have deployed the Grafana Helm Chart with the dashboard sidecar enabled, you can apply the dashboards.yaml with the following command:

`kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/monitoring/main/grafana/dashboards.yaml`

For reference, you need to supply the following values:

```yaml
sidecar:
  dashboards:
    enabled: true
    searchNamespace: ALL
```
