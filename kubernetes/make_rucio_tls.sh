#! /bin/bash

kubectl delete secret tls-secret --namespace=kube-system
kubectl delete secret tls-secret 

openssl pkcs12 -in $HOME/ewvk8s-ggimapr6rucs-minion-0.p12 -clcerts -nokeys -out hostcert.pem
openssl pkcs12 -in $HOME/ewvk8s-ggimapr6rucs-minion-0.p12 -nocerts -nodes -out hostkey.pem

chmod 0600 hostkey.pem

kubectl create secret tls tls-secret --key hostkey.pem --cert hostcert.pem --namespace=kube-system
kubectl create secret tls tls-secret --key hostkey.pem --cert hostcert.pem 


rm hostcert.pem hostkey.pem
