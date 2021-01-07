# Troubleshooting

## Debugging pod

I've found that when troubleshooting pods in a kubernetes cluster it is sometimes useful to create an ubuntu pod or a python pod.

There is an easy way to do this, let's do a python pod by using this command `kubectl run python-debug --rm --tty -i --restart='Never' --image python:3.7-buster --command -- /bin/bash`:

```
$ kubectl run python-debug --rm --tty -i --restart='Never' --image python:3.7-buster --command -- /bin/bash
If you don't see a command prompt, try pressing enter.
root@python-debug:/#  
```

Then you can run your commands:

```
root@python-debug:/#  python --version
Python 3.7.9
root@python-debug:/# 
```

And when your done just type `exit`.

```
root@python-debug:/# exit
exit
pod "python-debug" deleted
$ 
```

## curl trick

curl ouptut of k8s call as body, or you could use any output.  The magic is using the pipe `|` into a curl command and then using the `--data-binary @-`:

```
kubectl get pod <pod_name> -o json | curl -H "Content-Type: application/json" -X POST --data-binary @- http://127.0.0.1:3000/api 
```

## DNS

Visit official kubernetes site for additional [DNS troubleshooting](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)

## Busybox

Create the busybox pod using the following command:

```
kubectl create -f https://raw.githubusercontent.com/randysimpson/tools/master/k8s/troubleshooting/busybox.yaml
```

If a specific namespace is desired use `--namespace=vmware-system-tmc`

From this pod you can query info about DNS or anything else a default pod would receive:

```
kubectl exec -ti busybox -- nslookup kubernetes.default
```

```
kubectl exec -ti busybox -n vmware-system-tmc -- cat /etc/resolv.conf
```

## License

MIT License

Copyright (©) 2019 - Randall Simpson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.