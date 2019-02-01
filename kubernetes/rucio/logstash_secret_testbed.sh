#! /bin/bash

# Create secrets for logstash

kubectl delete secret logstash-pipeline --namespace kube-system
kubectl create secret generic logstash-pipeline --from-file=pipeline-testbed.conf --namespace kube-system
