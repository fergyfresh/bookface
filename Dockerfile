FROM python:3.6-alpine as intermediate
MAINTAINER Billy Ferguson <william.d.ferg@gmail.com>

# Variables
ENV PYTHONUNBUFFERED=1

# Code
ADD /app /code

# OS Dependencies
RUN apk add --virtual .build-deps \
    gcc musl-dev postgresql-dev git \
    libffi-dev

# Install requirements
WORKDIR /pip-packages/
RUN pip download gunicorn
RUN pip download -r /code/requirements.txt


FROM python:3.6-alpine

# Variables
ENV PYTHONUNBUFFERED=1

RUN apk add --virtual .build-deps \
    openssl-dev libffi-dev gcc musl-dev postgresql-dev 

COPY --from=intermediate /pip-packages/ /pip-packages/
RUN pip install --no-index --no-build-isolation --find-links=/pip-packages/ /pip-packages/*
ADD /app /code

# Clean-up
WORKDIR /code
RUN rm -rf *.txt *.json .git* .pylint* .coverage* architecture* doxyfile /pip-packages/
RUN apk --purge del .build-deps

# Start-up script
COPY start.sh /start.sh
RUN chmod +x /start.sh

RUN apk add --no-cache bash postgresql-libs

# HTTP Ports
EXPOSE 4000


CMD ["/start.sh", "-docker"]
