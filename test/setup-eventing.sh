#!/usr/bin/env bash

set -e

export SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"

kubectl apply -f https://github.com/knative/eventing/releases/latest/download/eventing-crds.yaml
kubectl wait --for=condition=Established --all crd -l knative.dev/crd-install="true"
kubectl apply -f https://github.com/knative/eventing/releases/latest/download/eventing-core.yaml
kubectl apply -f https://github.com/knative/eventing/releases/latest/download/in-memory-channel.yaml
kubectl apply -f https://github.com/knative/eventing/releases/latest/download/mt-channel-broker.yaml

# Expose the broker-ingress for testing
kubectl patch svc broker-ingress -n knative-eventing -p '{"spec": {"type": "LoadBalancer"}}'

