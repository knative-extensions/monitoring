#!/usr/bin/env bash

function jb () {
  go run github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@v0.6.0 $@
}

jb init
jb install github.com/grafana/grafonnet/gen/grafonnet-latest@main
