# Airflow Logging

> Airflow logging in Kubernetes can be tricky, here are a few examples.

When I setup Airflow on Kubernetes I had a few issues with logging.  I kept on seeing messages that the logs can't be retrieved from the UI.  I even tried outputting the pod log files but couldn't see any information.  But I have found a fix for that as well.

1. Logging to the output of the worker pod by using stdout.

    This could be useful if you are going to use fluentd for logging on your Kubernetes cluster.  It's not hard to set this up it just doesn't seem very intuitive.  First thing is to setup some environment variables in the configMap `airflow-env`:
    * `AIRFLOW__CORE__REMOTE_LOGGING: "True"`
    * `AIRFLOW__ELASTICSEARCH__WRITE_STDOUT: "True"`
    * `AIRFLOW__ELASTICSEARCH__HOST: "not-a-host"`

    There is an option to output the logs in json format, and that is just another environment variable in the same configMap `airflow-env`:

    ```
    AIRFLOW__ELASTICSEARCH__JSON_FORMAT: "True"
    ```

    And if you want specific fields for the json output you can specify them in an environment variable as well.  This is what the default looks like:

    ```
    AIRFLOW__ELASTICSEARCH__JSON_FIELDS: "asctime, filename, lineno, levelname, message"
    ```

    Now, if you use `kubectl logs <pod_name>` you will actually see the logging from the airflow tasks.

2. Logging to aws s3

    At the time of this writing, the Airflow documentation states that this is the preferred method for production logging.  It's not to hard to setup as long as you already have an s3 bucket created and the folder you are going to put the logs into already created.  Also the s3 bucket needs to be accessible by the Airflow pods in the k8s cluster.

    First you need to setup some environment variables in the configMap `airflow-env`:
    * `AIRFLOW__CORE__REMOTE_BASE_LOG_FOLDER: s3://logs`
    * `AIRFLOW__CORE__REMOTE_LOG_CONN_ID: aws_default`
    * `AIRFLOW__CORE__REMOTE_LOGGING: "True"`

    The `AIRFLOW__CORE__REMOTE_BASE_LOG_FOLDER` can be customized to the s3 folder you are wishing to put the log data into.  If you really want to you can change the name of the `AIRFLOW__CORE__REMOTE_LOG_CONN_ID`, but you will have to match it in your `airflow-connections` secret.

    The `airflow-connections` secret is used to create the connection to aws inside of Airflow.  The secret has an `add-connections.sh` file that will hold the connection information for aws.  An example of this file is:

    ```
    #!/usr/bin/env bash
    airflow connections --delete --conn_id aws_default
    airflow connections --add --conn_id aws_default --conn_type "aws"  --conn_extra '{"aws_access_key_id":"XXXXXXXXXXXXXXXXXXX","aws_secret_access_key":"XXXXXXXXXXXXXXX","host":"http://airflow-s3:33000","region_name":"us-east-1"}'
    ```

    If you need to create your own file you can do so then create the secret.  In this example the file created was called `add-connections.sh`:

    ```
    kubectl create secret generic airflow-connections --from-file=add-connections.sh=/path/to/add-connections.sh
    ```

    This add-connections.sh script needs to be added as a volume to the airflow pods so that it can be run when the airflow pods are created.  For this wee need to add it to the container as a volumeMount and then add it to the deployment as volume.

    ```
          volumeMounts:
            - name: connections
              mountPath: /home/airflow/connections
    ```

    ```
      volumes:
        - name: connections
          secret:
            secretName: airflow-connections
            defaultMode: 0755
    ```

    To see a complete example please view the the yaml file located at https://github.com/randysimpson/tools/blob/master/k8s/airflow/local_complete_airflow.yaml

### Debug level

What about when you can't see any debug messages from the python logging module?  Even if you pass the log level as Debug into the python code running in the Airflow tasks.

There is a fix, but it will turn on all the debug logging in airflow as well.  The solution is to add an environment variable to airflow to expose the level of logging.

`AIRFLOW__CORE__LOGGING_LEVEL=DEBUG`

In my example you would add this variable to the `airflow-env` configMap around this [local_complete_airflow.yaml -  Line 129](https://github.com/randysimpson/tools/blob/master/k8s/airflow/local_complete_airflow.yaml#L129).

---

### Licence

MIT License

Copyright (©) 2021 - Randall Simpson

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.