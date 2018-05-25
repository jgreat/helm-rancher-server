# rancher

Chart for installing Rancher Server on a Kubernetes cluster.

Rancher Resources:

* Rancher Docs: https://rancher.com/docs/rancher/v2.x/en/
* GitHub: https://github.com/rancher/rancher
* DockerHub Images: https://hub.docker.com/r/rancher/rancher

> NOTE: We recommend a small dedicated cluster for running Rancher Server.  Rancher will integrate with the local cluster and use the clusters etcd database as its database.

## Prerequisites

### nginx-ingress

This chart requires the `nginx-ingress` Ingress Controller.

Rancher's [RKE](https://github.com/rancher/rke) Kubernetes cluster build tool installs `nginx-ingress` by default. Other distributions of Kubernetes may require you to install the `nginx-ingress` controller.

You can find the chart here: [nginx-ingress](https://github.com/kubernetes/charts/tree/master/stable/nginx-ingress)

#### nginx-ingress install TL;DR

```shell
helm install stable/nginx-ingress --name nginx-ingress --namespace ingress
```

> NOTE: If you're going to use the Rancher Self-Signed certificates, see the special instructions for setting up [SSL passthrough](#Rancher-Self-Signed).

## Installing Rancher

The default install will deploy Rancher with 1 replica and use Rancher's self-signed SSL certificate listening on https://rancher.localhost

```shell
helm install stable/rancher --name rancher --namespace rancher-system
```

## Common Options

| Option | Default Value | Description |
| --- | --- | --- |
| `fqdn` | "rancher.localhost" | `string` - the Fully Qualified Domain Name for your Rancher Server |
| `ingress.tls` | "rancher" | `string` - Valid options: "rancher, publicCA, privateCA, letsEncrypt" |
| `letsEncrypt.email` | "none@example.com" | `string` - Your email address |
| `letsEncrypt.environment` | "staging" | `string` - Valid options: "staging, production" |
| `replicas` | 1 | `int` - number of rancher server replicas |

## Other Options

| Option | Default Value | Description |
| --- | --- | --- |
| `resources` | `{}` | `{}` - rancher pod resource requests & limits |
| `rancher_image_tag` | same as chart version | `string` - rancher/rancher image tag |

## HA

The default install runs Rancher with 1 replica.  Scale up after launching or use the `--set replicas=3` option.

## Hostname

The default install sets `rancher.localhost` as the fully qualified domain name to access Rancher. Use the `fqdn=` option to set it for your environment.

## SSL

### Rancher Self-Signed

```shell
helm install stable/rancher --name rancher --namespace rancher-system
```

The Default is set to `ingress.tls=rancher` so Rancher uses its self-signed certs. Your web browser will complain about being "insecure" but Rancher will still work.

You will need to configure your Ingress to enable SSL passthrough.

#### Passthrough: nginx-ingress from Helm Chart

If you're using `nginx-ingress` helm catalog add `--set controller.extraArgs.enable-ssl-passthrough=""` to your `helm install` command.

```shell
helm install stable/nginx-ingress --name nginx-ingress --namespace ingress \
--set controller.extraArgs.enable-ssl-passthrough=""
```

#### Passthrough: RKE install

Add the following `ingress` section to your RKE `cluster.yaml`

```yaml
ingress:
  provider: nginx
  extra_args:
    enable-ssl-passthrough: ""
```

### Public CA Signed Certs

Public CA signed certs can be added to the `rancher-system` namespace as the `tls-rancher` k8s secret.

Set `ingress.tls` to `publicCA` and `fqdn` to your cert common name.

```shell
helm install stable/rancher --name rancher --namespace rancher-system \
--set fqdn=your.domain.name.com \
--set ingress.tls=publicCA
```

Now that Rancher is running, see [Adding TLS Secrets](#Adding-TLS-Secrets) to publish the certificate files so Rancher and the Ingress Controller can use them.

### Private CA Signed Certs

Set `ingress.tls` to `privateCA` and `fqdn` to your cert common name.

```shell
helm install stable/rancher --name rancher --namespace rancher-system \
--set fqdn=your.domain.name.com \
--set ingress.tls=privateCA
```

Now that Rancher is running, see [Adding TLS Secrets](#Adding-TLS-Secrets) to publish the certificate files so Rancher and the Ingress Controller can use them.

### Adding TLS Secrets

Kubernetes will create all the objects and services for Rancher, but it will not become available until we populate the `rancher-tls` secret in the `rancher-system` namespace with the certificate and key.

Combine the server certificate followed by the intermediate cert chain your CA provided into a file named `tls.crt`. Copy your key into a file name `tls.key`.

> NOTE: The file names are important. The `kubectl create secret` command will create a secret with 2 key/value pairs.  `kubectl` will use the file name as the key name.

Use `kubectl` to create the secrets

```shell
kubectl -n rancher-system create secret generic tls-rancher --from-file=tls.crt --from-file=tls.key
```

#### Private CA Signed - Additional Steps

Rancher will need to have a copy of the CA cert to include when generating agent configs.

Copy the CA cert into a file named `cacerts.pem` and use `kubectl` to create the `tls-rancher-server` secret.

```shell
kubectl -n rancher-system create secret generic tls-rancher-server --from-file=cacerts.pem
```

### LetsEncrypt

LetsEncrypt will require the Rancher Server (ingress) to be accessible from the internet and a Public DNS record that points to the Rancher Server.

First install the `cert-manager` chart from Kubernetes Stable to manage the LetsEncrypt cert issuing and renewal.

```shell
helm install stable/cert-manager --name cert-manager --namespace kube-system
```

Now install Rancher with the LetsEncrypt options.

```shell
helm install rancher-server/rancher --name rancher --namespace rancher-system \
--set fqdn=your.domain.name.com \
--set ingress.tls=letsEncrypt \
--set letsEncrypt.email=<your email> \
--set letsEncrypt.environment=prod
```

## Connecting to Rancher

Rancher should now be accessible. Browse to `https://whatever.fqdn.is.set.to`

### Connecting to a `localhost` Rancher Server

By default Rancher is listening on `rancher.localhost` for connections. This default is handy if you want to run it on your local workstation. You will need to set up a `hosts` entry to connect.

* Windows - `c:\windows\system32\drivers\etc\hosts`
* Mac - `/etc/hosts`

```shell
127.0.0.1 rancher.local
```

Then browse to https://rancher.localhost
