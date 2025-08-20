#!/usr/bin/env bash

set -e

export SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"

# echo Setting up Kubernetes
kind delete cluster || true
kind create cluster

$SCRIPT_DIR/setup-prom-stack.sh
$SCRIPT_DIR/setup-jaeger-tracing.sh

