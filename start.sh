#!/bin/bash
echo Starting Gunicorn.

cd /code

# Only needed if doing static files
if [ ! -f /code/.build ]; then
  mkdir static
  python manage.py makemigrations
  python manage.py migrate
  date > /code/.build
fi

exec gunicorn bookface.wsgi:application \
    --bind 0.0.0.0:4000 \
    --workers 4
