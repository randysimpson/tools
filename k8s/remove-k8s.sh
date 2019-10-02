#!/bin/bash
# k8s reset script.
# 10/2/19 Randy Simpson
# need to run as sudo user or root

#reset kubeadm and all certs.
kubeadm reset -f

#clear the ip tables
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

#ensure that kubeadm is out and cleared.
apt-get purge kubeadm kubectl kubelet kubernetes-cni kube* -y

#run autoremove
apt-get autoremove -y

#remove kube files.
rm -rf ~/.kube

#remove any trace of etcd
rm -rf /var/lib/etcd/

#reboot
reboot