#!/usr/bin/env bash

set -e

export SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"

export URL="https://github.com/knative/eventing/releases/latest/download"

if [[ -n $NIGHTLY_BUILD ]]; then
  echo "Using latest nightly build"
  URL="https://storage.googleapis.com/knative-nightly/eventing/latest"
fi

kubectl apply -f "${URL}/eventing-crds.yaml"
kubectl wait --for=condition=Established --all crd -l knative.dev/crd-install="true"
kubectl apply -f "${URL}/eventing-core.yaml"
kubectl apply -f "${URL}/in-memory-channel.yaml"
kubectl apply -f "${URL}/mt-channel-broker.yaml"

# Expose the broker-ingress for testing
kubectl patch svc broker-ingress -n knative-eventing -p '{"spec": {"type": "LoadBalancer"}}'

kubectl patch configmap/config-observability \
  --namespace knative-eventing \
  --type merge \
  --patch '{
    "data":{
        "metrics-protocol":"prometheus",

        "request-metrics-protocol":"http/protobuf",
        "request-metrics-endpoint":"http://knative-kube-prometheus-st-prometheus.observability.svc:9090/api/v1/otlp/v1/metrics",

        "tracing-protocol": "http/protobuf",
        "tracing-endpoint": "http://jaeger-collector.observability.svc:4318/v1/traces"
      }
    }'

kubectl rollout restart deployments -n knative-eventing
kubectl apply -f config/eventing-monitors.yaml
kubectl apply -f config/configmap-eventing-dashboard.json

kubectl wait --for=condition=Available -n knative-eventing --all deployments --timeout=120s
