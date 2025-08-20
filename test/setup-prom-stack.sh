#!/usr/bin/env bash

set -e

export SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"

# echo Setting up Prometheus K8s Stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm install knative \
    prometheus-community/kube-prometheus-stack \
  --create-namespace \
  --namespace observability \
  -f ${SCRIPT_DIR}/../config/promstack-values.yaml


