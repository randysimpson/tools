# Bosh UI

This UI will show deployments, vm's and processes that Bosh Director has configured.

## Prerequisites

1. Prior to deploying the Bosh UI container, some environment variables need to be setup to communicate with the Bosh Director.

   * BOSH_CLIENT
   * BOSH_CLIENT_SECRET
   * BOSH_ENVIRONMENT

   These can be created using a command similar to:

   ```sh
   export BOSH_CLIENT=ops_manager BOSH_CLIENT_SECRET=xyz BOSH_ENVIRONMENT=172.31.0.2
   ```

   For ops manager environments the above variable information can be found at https://opsman.corp.local/api/v0/deployed/director/credentials/bosh_commandline_credentials
   
2. Next the Bosh Director certificate needs to be accessible for the communication with the Bosh Director.  The file can be placed anywhere but in this example it will have it's own directory.

   ```sh
   mkdir ~/bosh-ui
   ```

   With an environment that has ops manager, the following scp command can be used to get the file:

   ```sh
   scp ubuntu@opsman.corp.local:$BOSH_CA_CERT ~/bosh-ui/root_ca_certificate
   ```

   or if you know the file location:

   ```sh
   scp ubuntu@opsman.corp.local:/var/tempest/workspaces/default/root_ca_certificate ~/bosh-ui/root_ca_certificate
   ```

3. Make sure that `BOSH_CA_CERT` variable points to the cert location.  If the above directions were followed then issue:

   ```sh
   cd ~
   export BOSH_CA_CERT="$({ pwd; echo "bosh-ui";} | tr "\n" "/")"
   ```

## Setup/Install

The Bosh UI container can be deployed in various ways, but the two recommended was are:

* [Docker](#docker)
* [Kubernetes](#kubernetes)

---

### Docker

Docker must be installed and running.  Also the machine must have network access to the Bosh Director, which can be verified with `ping`.

Create the container in detached mode with the mount at the cert location and the port of 8080.

```sh
docker run --name bosh-ui --mount type=bind,source=$BOSH_CA_CERT,target=/tmp,readonly -e "BOSH_CLIENT=$BOSH_CLIENT" -e "BOSH_CLIENT_SECRET=$BOSH_CLIENT_SECRET" -e "BOSH_ENVIRONMENT=$BOSH_ENVIRONMENT" -p 8080:10000 -d randysimpson/bosh-ui:latest
```

The UI is now accessible from a browser using the IP of the machine running the container on port 8080.  To find the IP for the machine use `ifconfig`.

### Kubernetes

Kubernetes cluster must be up and running and network access to the Bosh Director from inside pods is necessary.  This can be verified by using the busybox pod and issuing ping to director IP.
```sh
kubectl create -f https://raw.githubusercontent.com/randysimpson/tools/master/k8s/troubleshooting/busybox.yaml
```
After the pod is running, issue:
```sh
kubectl exec -ti busybox -- ping 172.31.0.2
```

#### Deploy

There are 2 options for deploying bosh-ui in Kubernetes:
1. [Script](#issue-the-script)

 **or**

2. [Manually issuing commands](#manually-issue-the-following-commands)

---

#### Issue the script:

The easiest way to install the bosh ui on an existing Kubernetes cluster that has networking access to the bosh director VM is to download the following script and execute it to install the components.

```sh
$ curl -fsSL https://raw.githubusercontent.com/randysimpson/tools/master/bosh-ui/bosh-ui.sh -o bosh-ui.sh
$ sh bosh-ui.sh
```

Continue with [External IP](#external-ip)

---

#### Manually issue the following commands 

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

### External IP

To find the external IP issue:

```sh
kubectl get svc bosh-ui-frontend
```

Then from a web browser type in the ip address from previous command found in the `EXTERNAL-IP` column.

---

## Remove/Uninstall

1. Docker
```sh
docker stop bosh-ui
docker rm bosh-ui
```

2. Kubernetes
```sh
kubectl delete secret/bosh-ui-ca-cert
kubectl delete secret/bosh-ui-env
kubectl delete deployment.apps/bosh-ui-deployment
kubectl delete service/bosh-ui-frontend
```