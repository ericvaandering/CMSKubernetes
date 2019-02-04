#! /bin/bash

# Create secrets for logstash

kubectl delete secret cern-bundle --namespace kube-system
kubectl create secret generic  cern-bundle --from-file=/etc/pki/tls/certs/CERN-bundle.pem --namespace kube-system

# Start logstash and then the parts of filebeat

helm install  --name logstash --values cms-rucio-logstash.yml  stable/logstash
helm install --name filebeat-testbed --values cms-rucio-filebeat.yml  stable/filebeat

