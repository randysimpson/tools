# Airflow pod hook

> How to implement a pod annotation on airflow on Kubernetes using the pod_mutation_hook function

When I needed to add a pod annotation hook to my airflow pods it was a struggle to find any good documentation about it.  I had tried a few examples that I found but nothing seemed to put the actual annotation onto the pods.  I found that there was an update somewhere in airflow and they changed the type of the parameter that is on the hook and it needs a different notation to add the annotation.  The change that was made is a good one because this pod object is more robust.  In fact you can add labels or anything you desire.

For this example I'm going to add an annotation to the pods.  This is useful if your using aws EKS and your using kube2iam.  If you don't know what kube2iam is it's a k8s deployment that will allow pods in EKS to assume a role based off an annotation on the pod.

Well it was easy to figure out what I needed but it took a while to figure out the syntax for the `pod_mutation_hook`.  Hopefully this helps anyone else trying to do the same.  The first thing I did was create a ConfigMap that holds the overriding method (hook).  This method is called every time the kubernetes executor is generating a pod.  I also ensure that the method will use the existing annotations or a brand new empty dict if necessary.  My example is to use the annotation `iam.amazonaws.com/role=test`.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: airflow-local-settings
  labels:
    app: local-airflow
    chart: local-airflow-1.0.0
    release: airflow
    heritage: Tiller
data:
  airflow_local_settings.py: |
    def pod_mutation_hook(pod):
      pod.metadata.annotations = pod.metadata.annotations or {}
      pod.metadata.annotations['iam.amazonaws.com/role']= 'test'
```

Also we need to add the config setting to the configMap `airflow-env` - `AIRFLOW__KUBERNETES__AIRFLOW_LOCAL_SETTINGS_CONFIGMAP: "airflow-local-settings"`

I added the configmap as a volumeMount to the web and scheduler containers as well.

```
          volumeMounts:
            - name: airflow-local-settings
              mountPath: /opt/airflow/config
```

```
      volumes:
        - name: airflow-local-settings
          configMap:
            name: airflow-local-settings
            defaultMode: 0755
```

To see a complete example please view the the yaml file located at https://github.com/randysimpson/tools/blob/master/k8s/airflow/local_complete_airflow.yaml

---

### Licence

MIT License

Copyright (©) 2021 - Randall Simpson

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.