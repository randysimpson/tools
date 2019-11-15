#!/bin/bash
# k8s create single master script using kubeadm.
# 10/16/19 Randy Simpson
# need to run as sudo user or root and
# pass in networking desired as "calico" or "weave"
# then if your not as root user pass in $USER and $HOME variables so that kubectl can be setup correctly.

echo "kubeadm init with $1"
apt-get update && apt-get upgrade -y
sleep 3

# for calico pass network pod cidr network as kubeadm init parameter.
if [ "$1" = "calico" ]
then
  kubeadm init --pod-network-cidr=192.168.0.0/16
  sleep 15
fi

# for weave set bridge call iptables to 1, no kubeadm init args.
if [ "$1" = "weave" ]
then
  sysctl net.bridge.bridge-nf-call-iptables=1
  sleep 3
  
  kubeadm init
  sleep 15
fi

# for flannel set bridge call iptables to 1, also kubeadm init args.
if [ "$1" = "flannel" ]
then
  sysctl net.bridge.bridge-nf-call-iptables=1
  sleep 3
  
  kubeadm init --pod-network-cidr=10.244.0.0/16
  sleep 15
fi
  
# setup home directory fo kubectl
if [ "$3" != "" ]
then
  echo "Setup home directory for $2"
  mkdir -p $3/.kube
  sleep 2
  cp -i /etc/kubernetes/admin.conf $3/.kube/config
  sleep 2
  chown $2:$2 $3/.kube/config
  sleep 5
fi

# apply calico networking pods/services.
if [ "$1" = "calico" ]
then
  kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml
  sleep 15
fi

# apply weave networking pods/services
if [ "$1" = "weave" ]
then
  kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
  sleep 15
fi

# apply flannel networking pods/services
if [ "$1" = "flannel" ]
then
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml
  sleep 15
fi

kubectl get pods -A -o wide
sleep 5

kubectl get nodes -o wide