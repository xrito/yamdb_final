FROM python:3.7-slim
COPY ./ /app
RUN pip install -r /app/yamdb_final/requirements.txt
WORKDIR /app/yamdb_final/

CMD ["gunicorn", "api_yamdb.wsgi:application", "--bind", "0:5000" ]