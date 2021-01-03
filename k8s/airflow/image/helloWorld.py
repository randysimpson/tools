# MIT License

# Copyright (©) 2021 - Randall Simpson

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to 
# do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

from datetime import datetime
from datetime import date
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash_operator import BashOperator

from customCode.some_python_code import (
    run_test_func,
)

def print_hello():
    print("hello world")
    return 'Hello world!'


def get_date():
    return date.today().isoformat()


dag = DAG(
    'hello_world',
    description='Simple tutorial DAG',
    schedule_interval='*/5 * * * *',
    start_date=datetime(2020, 3, 20),
    catchup=False,
    is_paused_upon_creation=False
)


dummy_operator = DummyOperator(task_id='dummy_task', retries=3, dag=dag)


hello_operator = PythonOperator(
    task_id='hello_task',
    python_callable=print_hello,
    dag=dag
)

date_operator = PythonOperator(
    task_id='get_date',
    python_callable=get_date,
    dag=dag
)

task_run_test_func = PythonOperator(
    task_id="task_run_test_func",
    python_callable=run_test_func,
    retries=3,
    dag=dag,
)

bash_ls = BashOperator(
    task_id='bash_ls',
    bash_command="ls -lth",
    dag=dag,
)

bash_test = BashOperator(
    task_id='bash_test',
    bash_command="/opt/airflow/dags/test.sh Awesome ",
    dag=dag,
)

dummy_operator >> hello_operator >> date_operator >> task_run_test_func >> bash_test
task_run_test_func >> bash_ls
