#!/usr/bin/env bash

set -e

kubectl port-forward \
  -n observability svc/prometheus-operated 9090:9090 &

kubectl port-forward \
  -n observability svc/knative-grafana 3000:80 &

kubectl port-forward \
  -n observability svc/jaeger-collector 16686:16686 &

echo "Port forwards started. Press Enter to stop..."
read

# Kill all background jobs started by this shell
kill $(jobs -p)
