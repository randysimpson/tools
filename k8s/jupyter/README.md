# Jupyter/Conda/Pytorch

In this article we setup jupyter/anaconda/pitorch deployment on Kubernetes cluster.  If you don't need any machine learning abilities then the standard [Jupyter notebook deployment](https://simpsonhouse.hopto.org/blog/Setup%20Jupyter%20deployment%20on%20Kubernetes) should be just fine.

After taking a neural network machine learning class, I quickly found the need for pitorch.  The standard package from Jupyter would not allow me to install the necessary tools needed, so I decided to create my own container.  The docker image turned out to be 5.1 GB in size, which was disappointing, because I then had to bump up the hard drive size on my vm.

The image is based on ubuntu:18.04, which is probably why it's so big in size.  Basically after the base image, anaconda is installed, and conda is initialized.  Then pytorch is installed and Jupyter notebook is started.

If your the type that doesn't want to set everything up for yourself, there is a script that can be run using the following:

```
wget https://raw.githubusercontent.com/randysimpson/tools/master/k8s/jupyter/create.sh
sudo sh create.sh
```

The image can be found at [docker hub](https://hub.docker.com/r/randysimpson/jupyter-conda-pitorch) and installed on a machine with docker by using `docker run --name jupyter -d -p 8888:8888 -v /host/path:/root/notebooks -v /host/path:/root/.jupyter randysimpson/jupyter-conda-pytorch:v1.0`.  You will want to change `/host/path` with a folder on your machine to read/write notebook information and jupyter settings.

Of course we want to run this thing using Kubernetes though.  Let's create a PVC that we can use to hold the data, but before we do that we will need a PV.

#### Persistent Volumes

You can read more about Persistent Volumes on the [official Kubernetes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) web site.  It's a way of abstracting the actual storage into storage classes so that Kubernetes can use them like resources, much like a node in the cluster is a resource.  The idea is that an administrator will create the PV for a user to consume with PVC.  The relationship for Persistent Volume Claim (PVC) and a Persistent Volume (PV) is meant to be used in the same manner that a Pod uses resources on a Node.

There are many different types of PV's available to use and the choices will depend on your infrastructure.  For example if your using AWS then AWSElasticBlockStore would be a great choice, and GCP would use the GCEPersistentDisk.  But if your using a home lab then you might not have all those options.  You can still use local or HostPath or if you have NFS setup then that would be an option as well.  There is examples of each of the types as well as some great explanations on the [official Kubernetes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) web site.  For this article we will use the local PV type.

##### Local

To setup a local PV we are going to first create a directory to store the data into.  For this example we will use our k8server1 machine and store the data into `/data/jupyter`.

```
sudo mkdir -p /data/jupyter
```

Then the yaml to create the PV just looks like the following, but if your node name is different just adjust the value for the node selector to be the name of your node instead of `k8server1`.  For my example I used the filename [local-pv.yaml](https://raw.githubusercontent.com/randysimpson/tools/master/k8s/jupyter/local-pv.yaml):
 
```
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    type: local
  name: jupyter-local
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /data/jupyter
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - k8server1
```

You can create the pv by issuing the command:

```
kubectl create -f https://raw.githubusercontent.com/randysimpson/tools/master/k8s/jupyter/local-pv.yaml
```

#### Persistant Volume Claim

Then next step is to create a PVC to use that PV.  For my example I used the filename [pvc.yaml](https://raw.githubusercontent.com/randysimpson/tools/master/k8s/jupyter/pvc.yaml):

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jupyter
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  volumeMode: Filesystem
  volumeName: jupyter-local
```

To create the pvc issue:

```
kubectl create -f https://raw.githubusercontent.com/randysimpson/tools/master/k8s/jupyter/pvc.yaml
```

#### Deployment

Now create a deployment that will use that PVC as a volume to store data.  This deployment does not need any special permissions to run, we are just running the container on port 8888 and using a volume mount.

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: jupyter
  name: jupyter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jupyter
  template:
    metadata:
      labels:
        app: jupyter
    spec:
      containers:
      - image: randysimpson/jupyter-conda-pitorch:v1.0
        imagePullPolicy: IfNotPresent
        name: jupyter
        ports:
        - containerPort: 8888
          protocol: TCP
        volumeMounts:
        - mountPath: /root/notebooks
          name: data
        - mountPath: /root/.jupyter
          name: data
      nodeSelector:
        kubernetes.io/arch: amd64
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: jupyter
```

To create this just run the following command:

```
kubectl create -f https://raw.githubusercontent.com/randysimpson/tools/master/k8s/jupyter/deploy.yaml
```

#### Service

The last thing we need to do is expose the deployment so that we can reach it from outside the k8s cluster.  The easy way to do this is to use the `kubectl expose` command:

```
kubectl expose deployment jupyter --type=NodePort
```

#### Verify

Once the notebook has been deployed the pods can be verified by using:

```
rsimpson@k8server1:~$ kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
jupyter-5c66b4f586-lqbzj            1/1     Running   0          2m
```

The service can be verified by using:

```
rsimpson@k8server1:~$ kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)           AGE
jupyter      NodePort    10.100.31.97   <none>        34353:30991/TCP   2m
kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP           58d
```

Now the service is exposed on master and worker nodes on port 30991.  So lets go to a browser and visit the master node in a browser and get to your jupyter notebook.  In my example the master node is k8server1, therefore the url is `k8server1:30991`

![error loading](https://simpsonhouse.hopto.org/images/jupyter_web.PNG)

One option to get the token is to use the following command:

```
kubectl get pods | grep jupyter | awk '{print $1}' | xargs kubectl logs | grep token | sed 1q | sed -e 's/.*token=//'
```

Another option is to get the token from the jupyter logs.  You can use the pod id and issue the kubectl logs command:

```
rsimpson@k8server1:~$ kubectl logs jupyter-5c66b4f586-lqbzj
Executing the command: jupyter notebook
[I 13:02:24.814 NotebookApp] Writing notebook server cookie secret to /home/jovyan/.local/share/jupyter/runtime/notebook_cookie_secret
[I 13:02:26.961 NotebookApp] JupyterLab extension loaded from /opt/conda/lib/python3.7/site-packages/jupyterlab
[I 13:02:26.961 NotebookApp] JupyterLab application directory is /opt/conda/share/jupyter/lab
[I 13:02:26.971 NotebookApp] Serving notebooks from local directory: /home/jovyan
[I 13:02:26.971 NotebookApp] The Jupyter Notebook is running at:
[I 13:02:26.972 NotebookApp] http://jupyter-5c66b4f586-lqbzj:8888/?token=e59ae510437ffd231c4ef69b15d97d0ff115cdaaa23fe5e2
[I 13:02:26.972 NotebookApp]  or http://127.0.0.1:8888/?token=e59ae510437ffd231c4ef69b15d97d0ff115cdaaa23fe5e2
[I 13:02:26.972 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[C 13:02:27.007 NotebookApp]

    To access the notebook, open this file in a browser:
        file:///home/jovyan/.local/share/jupyter/runtime/nbserver-6-open.html
    Or copy and paste one of these URLs:
        http://jupyter-5c66b4f586-lqbzj:8888/?token=e59ae510437ffd231c4ef69b15d97d0ff115cdaaa23fe5e2
     or http://127.0.0.1:8888/?token=e59ae510437ffd231c4ef69b15d97d0ff115cdaaa23fe5e2
```

So the token in my example is `e59ae510437ffd231c4ef69b15d97d0ff115cdaaa23fe5e2`.  After entering into the token field and clicking "Log in", you will have access to jupyter!

![error loading](https://simpsonhouse.hopto.org/images/jupyter_success.PNG)

#### Summary

That's how you setup an jupyter notebook on a Kubernetes!

Please be sure to check out other topics - [Blog Posts](https://simpsonhouse.hopto.org/blog/).