# K8s scripts

## install-kubeadm.sh

This script will install prereqs for kubernetes to be installed using kubeadm.  It installs docker, kubeadm, kubelet, kubectl and turns swap off.

```sh
wget https://raw.githubusercontent.com/randysimpson/tools/master/k8s/install-kubeadm.sh
sudo sh install-kubeadm.sh $USER
```

or a root user can just issue `sudo sh install-kubeadm.sh`.

example output:

```sh
ubuntu@worker-1:~$ sudo sh install-kubeadm.sh $USER
[sudo] password for ubuntu:
Update and upgrade local node
Hit:1 http://us.archive.ubuntu.com/ubuntu bionic InRelease
Get:2 http://security.ubuntu.com/ubuntu bionic-security InRelease [88.7 kB]
Get:3 http://us.archive.ubuntu.com/ubuntu bionic-updates InRelease [88.7 kB]
Get:4 http://us.archive.ubuntu.com/ubuntu bionic-backports InRelease [74.6 kB]
Fetched 252 kB in 1s (181 kB/s)
Reading package lists... Done
Reading package lists... Done
Building dependency tree
Reading state information... Done
Calculating upgrade... Done
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Turn swap off
Comment swap line in /etc/fstab
Install Docker
Hit:1 http://us.archive.ubuntu.com/ubuntu bionic InRelease
Get:2 http://security.ubuntu.com/ubuntu bionic-security InRelease [88.7 kB]
Get:3 http://us.archive.ubuntu.com/ubuntu bionic-updates InRelease [88.7 kB]
Get:4 http://us.archive.ubuntu.com/ubuntu bionic-backports InRelease [74.6 kB]
Fetched 252 kB in 1s (187 kB/s)
Reading package lists... 72%

...omitted for clarity...

Unpacking kubeadm (1.16.3-00) ...
Setting up conntrack (1:1.4.4+snapshot20161117-6ubuntu2) ...
Setting up kubernetes-cni (0.7.5-00) ...
Setting up cri-tools (1.13.0-00) ...
Setting up socat (1.7.3.2-2ubuntu2) ...
Setting up kubelet (1.16.3-00) ...
Created symlink /etc/systemd/system/multi-user.target.wants/kubelet.service → /lib/systemd/system/kubelet.service.
Setting up kubectl (1.16.3-00) ...
Setting up kubeadm (1.16.3-00) ...
Processing triggers for man-db (2.8.3-2ubuntu0.1) ...
kubelet set on hold.
kubeadm set on hold.
kubectl set on hold.
```

## create-master.sh

This script will use kubeadm to create a single master node, with calico network setup.

```sh
wget https://raw.githubusercontent.com/randysimpson/tools/master/k8s/create-master.sh
sudo sh create-master.sh weave $USER $HOME
```

### Networking Options
* weave networking then issue `sudo sh create-master.sh weave $USER $HOME`.
* calico networking then issue `sudo sh create-master.sh calico $USER $HOME`.
* flannel networking then issue `sudo sh create-master.sh flannel $USER $HOME`.

example output for weave:

```sh
ubuntu@master-1:~$ sudo sh create-master.sh $HOME weave
kubeadm init with weave
Hit:1 https://download.docker.com/linux/ubuntu bionic InRelease
Get:2 http://security.ubuntu.com/ubuntu bionic-security InRelease [88.7 kB]
Hit:4 http://us.archive.ubuntu.com/ubuntu bionic InRelease
Get:5 http://us.archive.ubuntu.com/ubuntu bionic-updates InRelease [88.7 kB]
Hit:3 https://packages.cloud.google.com/apt kubernetes-xenial InRelease
Get:6 http://us.archive.ubuntu.com/ubuntu bionic-backports InRelease [74.6 kB]
Fetched 252 kB in 6s (39.4 kB/s)
Reading package lists... Done
Reading package lists... Done
Building dependency tree
Reading state information... Done
Calculating upgrade... Done
The following packages have been kept back:
  docker-ce
0 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
net.bridge.bridge-nf-call-iptables = 1
[init] Using Kubernetes version: v1.16.3
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Activating the kubelet service
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [master-1 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.0.2]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [master-1 localhost] and IPs [192.168.0.2 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [master-1 localhost] and IPs [192.168.0.2 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 36.003655 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.16" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node master-1 as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node master-1 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: fo380g.qywsgc0f08126yvf
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.0.2:6443 --token fo380g.qywsgc0f08126yvf \
    --discovery-token-ca-cert-hash sha256:860e1ccf2dc0a998ec2b3781c5672eadeed8f9621c79ce3bed209b6094dac63c
serviceaccount/weave-net created
clusterrole.rbac.authorization.k8s.io/weave-net created
clusterrolebinding.rbac.authorization.k8s.io/weave-net created
role.rbac.authorization.k8s.io/weave-net created
rolebinding.rbac.authorization.k8s.io/weave-net created
daemonset.apps/weave-net created
NAMESPACE     NAME                       READY   STATUS              RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
kube-system   coredns-5644d7b6d9-6s974   0/1     Pending             0          24s   <none>        <none>     <none>           <none>
kube-system   coredns-5644d7b6d9-mrqqq   0/1     Pending             0          24s   <none>        <none>     <none>           <none>
kube-system   kube-proxy-4fpwm           1/1     Running             0          24s   192.168.0.2   master-1   <none>           <none>
kube-system   weave-net-pph9n            0/2     ContainerCreating   0          10s   192.168.0.2   master-1   <none>           <none>
NAME       STATUS     ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master-1   NotReady   master   39s   v1.16.3   192.168.0.2   <none>        Ubuntu 18.04.3 LTS   4.15.0-70-generic   docker://18.6.2
```

## remove-k8s.sh

This script will remove k8s from ubuntu machine.

```sh
wget https://raw.githubusercontent.com/randysimpson/tools/master/k8s/remove-k8s.sh
sudo sh remove-k8s.sh
```