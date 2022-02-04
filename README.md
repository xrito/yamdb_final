# Проект DevOps (Development Operations) и идеи Continuous Integration (CI) для api_yamdb

Исходный код из командного проекта [api_yamdb](https://github.com/xrito/api_yamdb)  

Проект будет доступен по адресу: [ссылка](http://51.250.5.101/api/v1/titles/)

Документация API: [ссылка](http://51.250.5.101/redoc/)

## Запуск проекта на боевом сервере
Запуск состоит из четырех шагов:
Комманда git push является триггером workflow проекта.
При выполнении команды git push запустится набор блоков комманд jobs (см. файл yamdb_workflow.yaml).
Последовательно будут выполнены следующие блоки:
* tests - тестирование проекта на соответствие PEP8 и тестам pytest.
* build_and_push_to_docker_hub - при успешном прохождении тестов собирается образ (image) для docker контейнера 
и отправлятеся в DockerHub
* deploy - после отправки образа на DockerHub начинается деплой проекта на сервере.
* send_message Отправка уведомления в телеграм.

Для Continuous Integration в проекте используется облачный сервис GitHub Actions.
Для него описана последовательность команд (workflow), которая будет выполняться после события push в репозиторий.

### Подготовка и запуск проекта
- В настройках репозитория в разделе Actions secrets укажите все ключи:
  * PASSWORD - пароль от DockerHub;
  * USERNAME - имя пользователя на DockerHub;
  * HOST - ip-адрес сервера;
  * SSH_KEY - приватный ssh ключ;
  * TELEGRAM_TO - id своего телеграм-аккаунта
  * TELEGRAM_TOKEN - токен бота 

- Установите docker на сервер:
```
sudo apt install docker.io
```
- Установите docker-compose на сервер:
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
```
sudo chmod +x /usr/local/bin/docker-compose
```
- Скопируйте файлы docker-compose.yaml и nginx/default.conf из проекта на сервер:
```
scp docker-compose.yaml <username>@<host>/home/<username>/docker-compose.yaml
scp default.conf <username>@<host>/home/<username>/nginx/default.conf
```
- После успешного деплоя зайдите на боевой сервер и выполните команды миграции, создания суперпользователя и сбора статики
```
docker-compose exec web python manage.py makemigrations
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
docker-compose exec web python manage.py collectstatic --no-input 
```
- Описание команды для заполнения базы данными
```
Для переноса данных с ранее созданного файла fixtures.json на PostgreSQL выполнить команду:
  docker-compose exec web python manage.py shell 
  >>> from django.contrib.contenttypes.models import ContentType
  >>> ContentType.objects.all().delete()
  >>> quit()
docker-compose exec web python manage.py loaddata fixtures.json
```
Для остановки и удаления контейнеров и образов на сервере:
```
sudo docker stop $(sudo docker ps -a -q) && sudo docker rm $(sudo docker ps -a -q) && sudo docker rmi $(sudo docker images -q)
```
Для удаления volume базы данных:
```
sudo docker volume rm yamdb_final_postgres_data
```

![example workflow](https://github.com/xrito/yamdb_final/actions/workflows/yamdb_workflow.yml/badge.svg)
[![Python](https://img.shields.io/badge/-Python-464646?style=flat-square&logo=Python)](https://www.python.org/)
[![Django](https://img.shields.io/badge/-Django-464646?style=flat-square&logo=Django)](https://www.djangoproject.com/)
[![Django REST Framework](https://img.shields.io/badge/-Django%20REST%20Framework-464646?style=flat-square&logo=Django%20REST%20Framework)](https://www.django-rest-framework.org/)
[![PostgreSQL](https://img.shields.io/badge/-PostgreSQL-464646?style=flat-square&logo=PostgreSQL)](https://www.postgresql.org/)
[![Nginx](https://img.shields.io/badge/-NGINX-464646?style=flat-square&logo=NGINX)](https://nginx.org/ru/)
[![gunicorn](https://img.shields.io/badge/-gunicorn-464646?style=flat-square&logo=gunicorn)](https://gunicorn.org/)
[![docker](https://img.shields.io/badge/-Docker-464646?style=flat-square&logo=docker)](https://www.docker.com/)
[![GitHub%20Actions](https://img.shields.io/badge/-GitHub%20Actions-464646?style=flat-square&logo=GitHub%20actions)](https://github.com/features/actions)
[![Yandex.Cloud](https://img.shields.io/badge/-Yandex.Cloud-464646?style=flat-square&logo=Yandex.Cloud)](https://cloud.yandex.ru/)
