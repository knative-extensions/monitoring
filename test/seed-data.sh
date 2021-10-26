#!/usr/bin/env bash

kubectl wait --for=condition=Ready=true ksvc/hello --timeout=60s -n event-example

SERVING_LB=$(kubectl get svc/kourier -n kourier-system -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
EVENTING_LB=$(kubectl get svc/broker-ingress -n knative-eventing -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo Hitting Knative Service Endpoint

targets="$(mktemp)"
body="$(mktemp)"

cat<<EOF > "$targets"
GET http://$SERVING_LB
Host: hello.event-example.example.com
EOF

docker run --rm -i --network=kind -v "$targets":/targets peterevans/vegeta sh <<EOF
  vegeta attack -rate=10 -duration=10s -targets=/targets | vegeta report
EOF


cat<<EOF > "$targets"
POST http://$EVENTING_LB/event-example/default
Host: broker-ingress.knative-eventing.svc.cluster.local
Ce-Id: say-hello-goodbye
Ce-Specversion: 1.0
Ce-Type: greeting
Ce-Source: sendoff
Content-Type: application/json
EOF

cat<<EOF > "$body"
{"msg":"Hello Knative! Goodbye Knative!"}
EOF

echo Hitting Knative Eventing Broker - say-hello-goodbye
docker run --rm -i --network=kind -v "$targets":/targets -v "$body":/body peterevans/vegeta sh <<EOF
  vegeta attack -rate=10 -duration=10s -targets=/targets -body=/body | vegeta report
EOF

cat<<EOF > "$targets"
POST http://$EVENTING_LB/event-example/default
Host: broker-ingress.knative-eventing.svc.cluster.local
Ce-Id: say-goodbye
Ce-Specversion: 1.0
Ce-Type: not-greeting
Ce-Source: sendoff
Content-Type: application/json
EOF

cat<<EOF > "$body"
{"msg":"Goodbye Knative!"}
EOF

echo Hitting Knative Eventing Broker - say-goodbye
docker run --rm -i --network=kind -v "$targets":/targets -v "$body":/body peterevans/vegeta sh <<EOF
  vegeta attack -rate=10 -duration=10s -targets=/targets -body=/body | vegeta report
EOF
