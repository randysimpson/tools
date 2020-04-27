#!/bin/bash
# script to create jupyter deployment on k8s.
# © Copyright 2020
# 04/27/20 Randy Simpson
# need to run as sudo user or root

echo "Create PV of type local"
mkdir -p /data/jupyter
sleep 3

kubectl create -f https://raw.githubusercontent.com/randysimpson/tools/master/k8s/jupyter/local-pv.yaml
sleep 3

kubectl create -f https://raw.githubusercontent.com/randysimpson/tools/master/k8s/jupyter/pvc.yaml
sleep 3

echo "Create jupyter deployment"
kubectl create -f https://raw.githubusercontent.com/randysimpson/tools/master/k8s/jupyter/deployment.yaml
sleep 15

echo "Waiting for pod to reach running status..."
export STATUS=kubectl get pods | grep jupyter | awk '{print $3}'
while [ "$STATUS" != "Running"]
do
  sleep 30
  export STATUS=kubectl get pods | grep jupyter | awk '{print $3}'
done

echo "Creating service"
kubectl expose deployment jupyter --type=NodePort
sleep 30

export JUP_PORT=$(kubectl get svc jupyter -o json | jq '.spec.ports[0].nodePort')
export JUP_HOST=$(kubectl get nodes | grep Ready | sed 1q | awk '{print $1}')
export JUP_TOKEN=$(kubectl get pods | grep jupyter | awk '{print $1}' | xargs kubectl logs | grep token | sed 1q | sed -e 's/.*token=//')

echo ""
echo "Success!"
echo ""
echo "Connect to Jupyter by using the following URL:"
echo ""
echo "http://$JUP_HOST:$JUP_PORT"
echo ""
echo "Token is: $JUP_TOKEN"