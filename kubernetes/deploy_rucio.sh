#!/usr/bin/env bash

export RUCIO_GIT=$HOME/rucio
pushd $RUCIO_GIT; git pull; popd

export RUCIO_KUB=$RUCIO_GIT/etc/docker/kubernetes

kubectl create secret generic dburl --from-file=DBURL.txt

# Label all the nodes with ingress

kubectl get pods -o json | jq '.items[] | .spec.nodeName' -r | sort|uniq | xargs -I % kubectl label node --overwrite % role=ingress

kubectl apply -f rucio-server.yaml


exit



