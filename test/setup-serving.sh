#!/usr/bin/env bash

set -e

export SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"

export URL="https://github.com/knative/serving/releases/latest/download"
export KOURIER_URL="https://github.com/knative-extensions/net-kourier/releases/latest/download"

if [[ -n "$LATEST_BUILD" ]]; then
  echo "Using latest nightly build"
  URL="https://storage.googleapis.com/knative-nightly/serving/latest"
  KOURIER_URL="https://storage.googleapis.com/knative-nightly/net-kourier/latest"
fi

kubectl apply -f "${URL}/serving-crds.yaml"
kubectl wait --for=condition=Established --all crd -l knative.dev/crd-install="true"
kubectl apply -f "${URL}/serving-core.yaml"
kubectl wait --for=condition=Available -n knative-serving --all deployments

kubectl apply -f "${KOURIER_URL}/kourier.yaml"

kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data": {
    "ingress.class":"kourier.ingress.networking.knative.dev"
  }}'

kubectl patch configmap/config-domain \
    --namespace knative-serving \
    --type merge \
    --patch '{"data":{"example.com":""}}'

kubectl patch configmap/config-observability \
  --namespace knative-serving \
  --type merge \
  --patch '{
    "data":{
        "metrics-protocol":"prometheus",

        "request-metrics-protocol":"http/protobuf",
        "request-metrics-endpoint":"http://knative-kube-prometheus-st-prometheus.observability.svc:9090/api/v1/otlp/v1/metrics",

        "tracing-protocol":      "http/protobuf",
        "tracing-endpoint":      "http://jaeger-collector.observability.svc:4318/v1/traces",
        "tracing-sampling-rate": "1"
      }
    }'

kubectl rollout restart deployments -n knative-serving

kubectl apply -f config/serving-monitors.yaml
kubectl apply -f config/configmap-serving-dashboard.json

kubectl wait --for=condition=Available -n knative-serving --all deployments
