#!/bin/bash
# k8s install kubeadm, kubelet and kubectl.
# 10/16/19 Randy Simpson
# need to run as sudo user or root, and if you want to
# add a user to the docker group they will be able to run
# docker without using sudo.
# ./install-kubeadm.sh <username>

echo "Update and upgrade local node"
apt-get update && apt-get upgrade -y
sleep 3


echo "Turn swap off"
swapoff -a
sleep 3

echo "Install Docker"
# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install apt-transport-https ca-certificates curl software-properties-common
sleep 3

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
sleep 3

### Add Docker apt repository.
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
sleep 3

## Install Docker CE.
apt-get update && apt-get install docker-ce=18.06.2~ce~3-0~ubuntu
sleep 3

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d
sleep 3

#check if username paramager is passed in.
if ["$1" != "" ]; then
  usermod -aG docker $1
fi


# Restart docker.
systemctl daemon-reload
sleep 3
systemctl restart docker
sleep 3

apt-get update && apt-get install -y apt-transport-https curl
sleep 3
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
sleep 3
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sleep 3
apt-get update
sleep 3

echo "install kubeadm, kubelet, kubectl"
apt-get install -y kubelet kubeadm kubectl
sleep 3
apt-mark hold kubelet kubeadm kubectl