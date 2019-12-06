### CMS Promeetheus service
The [Prometheus](https://prometheus.io/) is  an open-source systems monitoring.

### CMS Prometheus deployment to k8s
We rely on [Prometheus-Opeartor](https://github.com/coreos/prometheus-operator)
CRD which can be used to easily deploy prometheus service on k8s
infrastructure.

The deployment of CMS Prometheus to k8s cluster is trivial. Please follow
these steps:
```
# login to lxplus-cloud
ssh lxplus-cloud

# create a cluster
create_cluster.sh <ssh key-pair> <cluster name>
# or you can use manual procedure, e.g.
openstack coe cluster create --keypair cloud \
    --cluster-template kubernetes-1.15.3-3 \
    --flavor m2.medium --master-flavor m2.medium --node-count 2 prometheus-cluster


# deploy Prometheus server, the deployment scripts expects
# that your area contains prometheus-config.yaml configuration file
deploy.sh
```

That's it!

#### Prometheus-operator deployment
We provide files `bundle.yaml` and `prom-oper.yaml` to deploy
prometheus cluster via
[Prometheus-operator](https://github.com/coreos/prometheus-operator)
deployment procedure. But we found certain limitation, in prometheus
configuration, which does not allow to integrate this
deployment with VictoriaMetrics service.

#### Prometheus custom deployment
The custom Prometheus deployment is based on `prometheus.yaml` manifest
file. It uses promtheus image and allows to provide custom configuration
of the service, e.g. add VictoriaMetrics service, use `file_sd_configs`
configuration, etc.

### Pushgateway service
The [Prometheus-pushgateway](https://github.com/prometheus/pushgateway)
service exists to allow ephemeral and batch jobs to expose their metrics to
Prometheus. Its deployment is done via `deploy.sh` script or can be
done manually as following
```
kubectl apply -f pushgateway.yaml
```
The service is open on port 30091 and
NATS subscriber can send any metrics to this service via simple
HTTP call, e.g.
```
echo "some_metric 3.14" | curl --data-binary @- http://cms-prometheus.cern.ch:30091/metrics/job/some_job
```

### VictoriaManifest backend
We also deploy [VictoriaMetrics](https://victoriametrics.com/) service
which can be used as Prometheus backend and long-term storage, as well
as a storage for NATS monitoring messages. It supports Prometheus
[PromQL](https://prometheus.io/docs/prometheus/latest/querying/basics/),
[Prometheus Query API](https://prometheus.io/docs/prometheus/latest/querying/api/),
and additional
[extensions](https://github.com/VictoriaMetrics/VictoriaMetrics/wiki/ExtendedPromQL)
which we can use for monitoring purposes. The VictoriaMetrics
provides high-performance, scalability, queyring, high data-compression,
and efficient storage, for all details please refer
to VictoriaMetrics [documentation](https://victoriametrics.github.io/#pure-go-build-cgo_enabled0)
and VictoriaMetrics
[benchmark](https://medium.com/@valyala/high-cardinality-tsdb-benchmarks-victoriametrics-vs-timescaledb-vs-influxdb-13e6ee64dd6b)
pages.

The deployment is done internally by `deploy.sh` or can be done
as simple as following:
```
kubectl apply -f victoria-metrics.yaml
```
The service operates on two ports, 30422 to insert data and
30428 to retrieve the data. The injected data should follow
[OpenTSDB](http://opentsdb.net/docs/build/html/user_guide/writing/index.html)
format, and we can insert and query data as following:
```
url="http://cms-prometheus.cern.ch"
purl=${url}:30422/api/put
rurl=${url}:30428/api/v1/export

# insert data into VictoriaMetrics
echo "put data into $purl"
curl -H 'Content-Type: application/json' -d '{"metric":"cms.dbs.exitCode", "value":8021, "tags":{"site":"T2_US", "task":"test", "log":"/path/file.log"}}' "$purl"

# query data from VictoriaMetrics
echo "get data from $rurl"
curl -G "$rurl" -d 'match[]=cms.dbs.exitCode'

# the output of query
put data into http://cms-prometheus.cern.ch:30422/api/put
get data from http://cms-prometheus.cern.ch:30428/api/v1/export
{"metric":{"__name__":"cms.dbs.exitCode","log":"/path/file.log","site":"T2_US","task":"test"},"values":[8021,8021],"timestamps":[1575635036000,1575635041000]}
```
For more information about VictoriaMetrics please see
its [FAQ](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/docs/FAQ.md)
and its
[Single-node](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/docs/Single-server-VictoriaMetrics.md#how-to-export-time-series)
tutorial.

### Content
Here we provide content of repository
```
# prometheus operator files
bundle.yaml           # create CRD bundle
prom-oper.yaml        # deployment manifest file

# aux files
create_cluster.sh     # script to create a cluster
create_secrets.sh     # script to create prometheus secrets
deploy.sh             # script to deploy all services
test_vm.sh            # script to test VictoriSecrets service

# service files
prometheus.yaml       # prometheus deployment manifest
pushgateway.yaml      # pushgateway deployment manifest
victoria-metrics.yaml # VictoriaMetrics manifest
```