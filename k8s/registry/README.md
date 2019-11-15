# Registry

## Local Registry

Deploy a local registry to store images.

To deploy a local storage/pv you can use the following yaml.  Feel free to modify the file to ensure the pv is persistent as per [Types of Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#types-of-persistent-volumes).

```
kubectl create -f https://raw.githubusercontent.com/randysimpson/tools/master/k8s/registry/localregistrypv.yaml --edit
```

Create the deployments/services.

```
kubectl create -f https://raw.githubusercontent.com/randysimpson/tools/master/k8s/registry/localregistry.yaml
```

You will then need to get the ip for the registry from `kubectl get svc`:

```
$ kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP    2d22h
nginx        ClusterIP   10.111.47.202    <none>        443/TCP    164m
registry     ClusterIP   10.109.174.105   <none>        5000/TCP   164m
```

Change the docker config to use `insecure-registries` __on all nodes in cluster__ with the ip from the last step:

   1. edit config
   ```
   $ sudo vim /etc/docker/daemon.json
   ```

   `{ "insecure-registries":["10.109.174.105:5000"] }`

   2. restart docker

   ```
   $ sudo systemctl restart docker.service
   ```
   
Tag images with `10.109.174.105:5000` prefix.

Note: _You might be able to use DNS name of `registry` instead of ip_

Copyright (©) 2019 - Randall Simpson