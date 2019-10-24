# K8s scripts

## remove-k8s.sh

This script will remove k8s from ubuntu machine.

```sh
curl -fsSL https://raw.githubusercontent.com/randysimpson/tools/master/k8s/remove-k8s.sh -o remove-k8s.sh
sudo sh remove-k8s.sh
```

## install-kubeadm.sh

This script will install prereqs for kubernetes to be installed using kubeadm.  It installs docker, kubeadm, kubelet, kubectl and turns swap off.

```sh
curl -fsSL https://raw.githubusercontent.com/randysimpson/tools/master/k8s/install-kubeadm.sh -o install-kubeadm.sh
sudo sh install-kubeadm.sh
```

To Install these and allow for a user to be able to issue docker commands use parameter of the username when issuing install command.  i.e. if username is ubuntu:

```
sudo sh install-kubeadm.sh ubuntu
```

## create-master.sh

This script will use kubeadm to create a single master node, with calico network setup.

```sh
curl -fsSL https://raw.githubusercontent.com/randysimpson/tools/master/k8s/create-master.sh -o create-master.sh
sudo sh create-master.sh $HOME
```