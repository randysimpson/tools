#!/bin/bash
# k8s reset script.
# 10/2/19 Randy Simpson
# need to run as sudo user or root

#reset kubeadm and all certs.
kubeadm reset -f
sleep 3

#clear the ip tables
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
sleep 3

#ensure that kubeadm is out and cleared.
apt-get purge kubeadm kubectl kubelet kubernetes-cni kube* -y --allow-change-held-packages
sleep 3

#run autoremove
apt-get autoremove -y
sleep 3

#remove kube files.
rm -rf ~/.kube
sleep 3

#remove any trace of etcd
rm -rf /var/lib/etcd/
sleep 3

#reboot
reboot