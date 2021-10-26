The test resources under `test/config` are for debugging the Service and Pod Monitors.

These test resources follow the examples from:
- https://knative.dev/development/developer/eventing/sources/apiserversource/getting-started/
- https://knative.dev/docs/eventing/getting-started/
- https://knative.dev/development/developer/eventing/sources/ping-source/

To spin up a test kind cluster run:

`./test/setup-kind.sh`


To seed the cluster with some initial data run:

`
./test/seed-data.sh
`
