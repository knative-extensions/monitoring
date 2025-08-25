#!/usr/bin/env bash

set -e

export SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"

# echo Setting up Kubernetes
kind delete cluster || true
kind create cluster

${SCRIPT_DIR}/setup-prom-stack.sh
${SCRIPT_DIR}/setup-jaeger-tracing.sh
${SCRIPT_DIR}/setup-serving.sh
${SCRIPT_DIR}/setup-eventing.sh

kubectl apply -f ${SCRIPT_DIR}/config
