# rancher

Chart for installing Rancher server on a Kubernetes cluster.

## Installing

Add this repo

```
helm repo add rancher-server https://jgreat.github.io/helm-rancher-server/charts
```

Install the rancher chart

```
helm install rancher-server/rancher --name rancher --namespace rancher-system
```

## Options

| Option | Default Value | Description |
| --- | --- | --- |
| `fqdn` | "rancher.localhost" | `string` - the Fully Qualified Domain Name for your Rancher Server |
| `ingress.tls` | "passthrough" | `string` - Valid options: "passthrough|cert|letsEncrypt" |
| `letsEncrypt.email` | "none@example.com" | `string` - Your email address |
| `letsEncrypt.enabled` | false | `bool` - Enable letEncrypt for SSL certs |
| `letsEncrypt.environment` | "staging" | `string` - Valid options: "staging|production" |
| `rancher_image_tag` | "stable" | `string` - rancher/rancher image tag |
| `replicas` | 1 | `int` - number of rancher server replicas |

## SSL

### Rancher Self-Signed (Default)

The Default is set to `passthrough` so Rancher uses its self-signed certs. Your web browser will complain, but Rancher will still work.

You may need to configure your Ingress to enable SSL passthrough. If you're using `ingress-nginx` helm catalog add `--set controller.extraArgs.enable-ssl-passthrough=""` to your `helm install` command.

### Your own Certs.
If you have your own certs and a DNS entry, you can add the certs to the `rancher-system` namespace as the `tls-rancher` k8s secret.

```
kubectl -n rancher-system create secret generic tls-rancher --from-file=tls.crt --from-file=tls.key
```

```
helm install rancher-server/rancher --name rancher --namespace rancher-system --set fqdn=your.domain.name.com --set ingress.tls=cert
```

### LetsEncrypt
LetsEncrypt will require the Rancher Server(ingress) to be accessible from the internet and a Public DNS record that points to the Rancher Server.

First install the `cert-manager` chart from Kubernetes Stable to mamage the LetsEncrypt cert issuing and renewal.

```
helm install stable/cert-manager --name cert-manager --namespace kube-system
```

Now install rancher with the LetsEncrypt options.
```
helm install rancher-server/rancher --name rancher --namespace rancher-system --set fqdn=your.domain.name.com --set ingress.tls=letsEncrypt --set letsEncrypt.enabled=true --set letsEncrypt.email=<your email> --set letsEncrypt.environment=prod
```

## Connecting to a `localhost` Rancher Server

By default Rancher is listening on `rancher.localhost` for connections. You will need to set up a `hosts` entry to connect.

* Windows - `c:\windows\system32\drivers\etc\hosts`
* Mac - `/etc/hosts`

```
127.0.0.1 rancher.local
```

Then browse to https://rancher.localhost

