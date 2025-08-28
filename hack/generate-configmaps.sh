
#!/usr/bin/env bash

# Copyright 2018 The Knative Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# rm -rf hack/charts/dashboards
# cp -r grafana/ hack/charts/dashboards
# helm template hack/charts/ > grafana/dashboards.yaml
# sed -i.bak '/knative-dashboards.yaml/d' grafana/dashboards.yaml
# rm -rf grafana/*.bak



jsonnet -J vendor -J dashboards/lib -e '
  local e = import "dashboards/serving-efficiency.libsonnet";
  local r = import "dashboards/serving-reconciler.libsonnet";

  {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      name: "serving-dashboards",
      namespace: "knative-serving",
      labels: { grafana_dashboard: "1" },
    },
    data: {
    "knative-serving-efficiency.json": std.manifestJson(e),
    "knative-serving-reconciler.json": std.manifestJson(r),
    },
  }
' > config/configmap-serving-dashboard.json


jsonnet -J vendor -J dashboards/lib -e '
  local e = import "dashboards/eventing-efficiency.libsonnet";

  {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      name: "eventing-dashboards",
      namespace: "knative-eventing",
      labels: { grafana_dashboard: "1" },
    },
    data: {
    "knative-eventing-efficiency.json": std.manifestJson(e),
    },
  }
' > config/configmap-eventing-dashboard.json

