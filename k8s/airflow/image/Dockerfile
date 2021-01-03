FROM apache/airflow:1.10.12-python3.6

COPY ./requirements.txt ./dags
RUN python -m pip install --user -r ./dags/requirements.txt

COPY *.py ./dags/
COPY ./customCode ./dags/customCode
COPY --chown=airflow:root test.sh ./dags/

RUN chmod +x ./dags/test.sh

CMD [ "airflow" "--help"]