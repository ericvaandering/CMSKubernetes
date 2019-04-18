#! /bin/sh

REPO=~/rucio-helm-charts # or rucio

SERVER_NAME=cms-rucio-dev
DAEMON_NAME=cms-ruciod-dev

# Ingress server

helm install stable/nginx-ingress --namespace kube-system --name ingress-nginx --values nginx-ingress.yaml

# Rucio server, daemons, and daemons for analysis

helm install --name $SERVER_NAME --values cms-rucio-common.yaml,cms-rucio-server-nginx.yaml,dev-rucio-server.yaml,dev-db.yaml,dev-release.yaml $REPO/rucio-server
helm install --name $DAEMON_NAME --values cms-rucio-common.yaml,cms-rucio-daemons.yaml,dev-rucio-daemons.yaml,dev-db.yaml,dev-release.yaml $REPO/rucio-daemons

# Graphite and other services
helm install --name graphite --values rucio-graphite.yaml,rucio-graphite-nginx.yaml,rucio-graphite-pvc.yaml,dev-graphite.yaml kiwigrid/graphite
helm install --name grafana --values rucio-grafana.yaml, dev-grafana.yaml stable/grafana
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode > dev_grafana_password.txt

# Filebeat and logstash
helm install --name logstash --values cms-rucio-logstash.yml,dev-logstash-filter.yaml stable/logstash
helm install --name filebeat --values cms-rucio-filebeat.yml  stable/filebeat

kubectl delete job --ignore-not-found=true fts
kubectl create job --from=cronjob/${DAEMON_NAME}-renew-fts-proxy fts

# Label is key to prevent it from also syncing datasets
kubectl apply -f testbed-sync-jobs.yaml -l syncs=rses

exit

# Set up landb loadbalance
numberIngressNodes=3
n=2
kubectl get node -o name | while read node; do
  [[ $((n++)) == $numberIngressNodes ]] && break
  kubectl label node ${node##node/} role=ingress
  cnames="cms-rucio-grafana-dev--load-${n}-,cms-rucio-graphite-dev--load-${n}-,cms-rucio-dev--load-${n}-,cms-rucio-auth-dev--load-${n}-"
  openstack server set --os-project-name CMSRucio --property landb-alias=$cnames ${node##node/}
  # teardown:
  # openstack server unset --os-project-name CMSRucio --property landb-alias ${node##node/}
done
