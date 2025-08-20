#!/usr/bin/env bash

set -e

export SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"

kubectl apply -f https://github.com/knative/serving/releases/latest/download/serving-crds.yaml
kubectl wait --for=condition=Established --all crd -l knative.dev/crd-install="true"
kubectl apply -f https://github.com/knative/serving/releases/latest/download/serving-core.yaml
kubectl wait --for=condition=Available -n knative-serving --all deployments

kubectl apply -f https://github.com/knative-extensions/net-kourier/releases/latest/download/kourier.yaml

kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

kubectl patch configmap/config-observability \
  --namespace knative-serving \
  --type merge \
  --patch '{
    "data":{
        "metrics-protocol":"prometheus",
        "request-metrics-protocol":"http/protobuf",
        "request-metrics-endpoint":"http://knative-kube-prometheus-st-prometheus.observability.svc:9090/api/v1/otlp/v1/metrics"
      }
    }'

kubectl rollout restart deployments -n knative-serving
