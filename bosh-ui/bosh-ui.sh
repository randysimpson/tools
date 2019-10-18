#!/bin/bash

#create ca cert secret
kubectl create secret generic bosh-ui-ca-cert \
  --from-file=root_ca_certificate=$BOSH_CA_CERT
  
#create secret for client, secret, and bosh environment.
kubectl create secret generic bosh-ui-env \
  --from-literal=BOSH-CLIENT=$BOSH_CLIENT \
  --from-literal=BOSH-CLIENT-SECRET=$BOSH_CLIENT_SECRET \
  --from-literal=BOSH-ENVIRONMENT=$BOSH_ENVIRONMENT

#create the deployment
kubectl create -f https://raw.githubusercontent.com/randysimpson/tools/master/bosh-ui/bosh-ui-deployment.yaml

#expose the deployment to loadbalancer.
kubectl expose deployment bosh-ui-deployment \
  --name=bosh-ui-frontend --port=80 \
  --target-port=10000 --type=LoadBalancer