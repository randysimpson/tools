#!/bin/bash
# k8s create single master script using kubeadm.
# 10/16/19 Randy Simpson
# need to run as sudo user or root and pass in $HOME env variable.

echo "kubeadm init with calico"
apt-get update && apt-get upgrade -y
sleep 3

kubeadm init --pod-network-cidr=192.168.0.0/16
sleep 5

if [ "$1" != "" ]
then
  mkdir -p $HOME/.kube
  sleep 2
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sleep 2
  chown $(id -u):$(id -g) $HOME/.kube/config
fi

kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml
sleep 10

kubectl get pods -A -o wide
sleep 5

kubectl get nodes -o wide