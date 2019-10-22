# Bosh UI

This UI will show deployments, vm's and processes that bosh is running.

## Setup

On a machine that has Kubernetes access and the environment variables setup for the Bosh-CLI, i.e.(`$BOSH_CA_CERT`, `$BOSH_CLIENT`, `$BOSH_CLIENT_SECRET`, `$BOSH_ENVIRONMENT`).

There are 2 options for deploying bosh-ui:
1. [Script](#issue-the-script)

 **or**

2. [Manually issuing commands](#manually-issue-the-following-commands)

---

### Issue the script:

The easiest way to install the bosh ui on an existing Kubernetes cluster that has networking access to the bosh director VM is to download the following script and execute it to install the components.

```sh
$ curl -fsSL https://raw.githubusercontent.com/randysimpson/tools/master/bosh-ui/bosh-ui.sh -o bosh-ui.sh
$ sh bosh-ui.sh
```

Continue with [External IP](#external-ip)

---

### Manually issue the following commands 

Create necessary k8s secrets:

```sh
kubectl create secret generic bosh-ui-ca-cert \
  --from-file=root_ca_certificate=$BOSH_CA_CERT
```

```sh
kubectl create secret generic bosh-ui-env \
  --from-literal=BOSH-CLIENT=$BOSH_CLIENT \
  --from-literal=BOSH-CLIENT-SECRET=$BOSH_CLIENT_SECRET \
  --from-literal=BOSH-ENVIRONMENT=$BOSH_ENVIRONMENT
```

To launch the deployment, service and ingress use the following:

```sh
kubectl create -f https://raw.githubusercontent.com/randysimpson/tools/master/bosh-ui/bosh-ui-deployment.yaml
```

Then expose the service on your loadbalancer:

```sh
kubectl expose deployment bosh-ui-deployment \
  --name=bosh-ui-frontend --port=80 \
  --target-port=10000 --type=LoadBalancer
```

Continue with [External IP](#external-ip)

---

## External IP

To find the external IP issue:

```sh
kubectl get svc bosh-ui-frontend
```

Then from a web browser type in the ip address from previous command.

---

## Remove/Uninstall

```sh
kubectl delete secret/bosh-ui-ca-cert
kubectl delete secret/bosh-ui-env
kubectl delete deployment.apps/bosh-ui-deployment
kubectl delete service/bosh-ui-frontend
```