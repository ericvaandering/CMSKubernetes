#! /bin/bash

# Create secrets for logstash

kubectl delete secret cern-bundle --namespace kube-system
kubectl create secret generic  cern-bundle --from-file=/etc/pki/tls/certs/CERN-bundle.pem --namespace kube-system

# Start logstash and then the parts of filebeat

kubectl apply -f logstash.yaml

kubectl apply -f filebeat-config.yaml
kubectl apply -f filebeat-clusterrole.yaml
kubectl apply -f filebeat-ds.yaml
