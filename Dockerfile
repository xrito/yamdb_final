FROM python:3.7-slim

WORKDIR /app

COPY /yamdb_final/requirements.txt .

RUN pip3 install -r /yamdb_final/requirements.txt --no-cache-dir

COPY . ./

CMD ["gunicorn", "api_yamdb.wsgi:application", "--bind", "0:5000" ]