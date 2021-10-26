#!/usr/bin/env bash

set -e

export SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"
export KNATIVE_VERSION=v0.26.0

# echo Setting up Kubernetes
kind delete cluster
kind create cluster

# echo Setting up MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/master/manifests/namespace.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/master/manifests/metallb.yaml

# This carves out the top end of the kind network subset
#
# Run: docker network inspect -f '{{.IPAM.Config}}' kind
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.18.255.200-172.18.255.250
EOF

# echo Setting up Prometheus K8s Stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install promstack -f $SCRIPT_DIR/values.yaml prometheus-community/kube-prometheus-stack

echo Setting up Serving
kubectl apply -f https://github.com/knative/serving/releases/download/${KNATIVE_VERSION}/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/${KNATIVE_VERSION}/serving-core.yaml

echo Setting up Kourier
kubectl apply -f https://github.com/knative-sandbox/net-kourier/releases/download/${KNATIVE_VERSION}/kourier.yaml
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

echo Setting up Eventing
kubectl apply -f https://github.com/knative/eventing/releases/download/${KNATIVE_VERSION}/eventing-crds.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/${KNATIVE_VERSION}/eventing-core.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/${KNATIVE_VERSION}/in-memory-channel.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/${KNATIVE_VERSION}/mt-channel-broker.yaml

# Expose the broker-ingress for testing
kubectl patch svc broker-ingress -n knative-eventing -p '{"spec": {"type": "LoadBalancer"}}'

echo Setting up Prometheus Monitors
kubectl apply -f $SCRIPT_DIR/../servicemonitor.yaml

echo Setting up Grafana Dashboards
kubectl apply -f $SCRIPT_DIR/../grafana/dashboards.yaml

# Consider making this wait smarter
sleep 60

echo Setup Test Resources
kubectl apply -f $SCRIPT_DIR/config
