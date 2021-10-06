# Sequencer Helm Chart

This helm chart deploys an instance of the Optimistic Rollup.

To run locally, be sure to enable Kubernetes for [Docker for Desktop](https://docs.docker.com/desktop/kubernetes/)
or run [kind](https://kind.sigs.k8s.io/).

The `kind.sh` script is provided to start a local kind cluster.

## Prerequisites

- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [helm](https://helm.sh/docs/intro/install/)
- [gcloud](https://cloud.google.com/sdk/docs/install)

```bash
$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
$ helm repo add jetstack https://charts.jetstack.io
$ helm repo update
```

Helm combines the `values.yaml` files and templates the values into the
files in the `templates` directory. The `-f` flag can be used to add additional
`values.yaml` files, merging the values together.
It is possible to see the output of the templates using the command:

```bash
$ helm template
```

## Usage

Be sure to set the `kubectl` context correctly before starting.

The common configuration is maintained in `values.yaml`. Environment specific
configuration can be found in `env` and the secrets are found in `secrets`.

To deploy a local system:
```bash
$ helm install sequencer -f env/local.yaml .
```
This will only work if the chart has yet to be installed.

To deploy a cloud based system, [cert-manager](https://cert-manager.io/docs/)
must first be deployed. This is possible with the `cert-manager.sh` command.

To deploy Goerli:
```bash
$ helm install sequencer -f values.yaml -f env/goerli.yaml -f secrets/goerli.yaml .
```

To upgrade a local system:
```bash
$ helm upgrade sequencer -f env/local.yaml
```

The upgrade command will make a new revision and make the minimal changes
required to deploy any changes in configuration. This is how one would
reconfigure the system. This will only work if the chart has already been
installed.

To delete the deployment:
```bash
$ helm delete sequencer
```

## Secrets

These secrets must be placed in a file in the `secrets` directory.

- `batch_submitter.Mnemonic`
- `batch_submitter.sentryDsn`
- `data_transport_layer.sentryDsn`
- `gcePersistentDisk.sequencer`
- `gcePersistentDisk.data_transport_layer`
- `letsencrypt.email`
- `cloudflare.api_token`
- `cloudflare.api_key`
- `cloudflare.api_email`
- `cloudflare.zone_id_filter`
- `ethereum_http_url`

## Persistent Volumes

To create a persistent volume, it will differ depending on the cloud backend.

For Google Cloud:

```bash
./gcloud-disks.sh <name of disk>
```

Both the `sequencer` and `data-transport-layer` require persistent
disks. The names of the disks are defined in `.Values.gcePersistentDisk`.

## nginx-ingress

This chart must be deployed before the sequencer. It is responsible
for managing a reverse proxy to the application itself. It is a subchart and
will be automatically deployed with the `sequencer` chart.

To install the `nginx-ingress` chart:

```bash
$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
$ helm repo update
```

To see the configuration:

```bash
$ helm show values ingress-nginx/ingress-nginx
```

## cert-manager

The [cert-manager](https://cert-manager.io) is useful for automating TLS certificate usage for
kubernetes based applications. This must be deployed before the sequencer.

To install `cert-manager`:

```bash
$ kubectl create namespace cert-manager
$ helm repo add jetstack https://charts.jetstack.io
$ helm repo update

$ ./cert-manager.sh
```

# Datadog

To add the [Datadog Helm Chart](https://github.com/DataDog/helm-charts/tree/master/charts/datadog)
use the following commands:

```bash
$ helm repo add datadog https://helm.datadoghq.com
$ helm repo add stable https://charts.helm.sh/stable
$ helm repo update

$ kubectl create namespace datadog
$ helm install datadog \
    --namespace datadog \
    --set datadog.apiKey=<api-key> \
    --set datadog.site='datadoghq.com' \
    --set datadog.logs.enabled=true \
    --set datadog.logs.containerCollectAll=true
```
