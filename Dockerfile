FROM python:3.10-slim-bullseye

ENV PYTHONUNBUFFERED 1
ARG DEV_BUILD
WORKDIR /app

RUN apt update \
  && apt install -y aria2 libpq-dev postgresql-client python3-dev \
  && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/
RUN pip install --no-cache-dir -U pip \
  && pip install --no-cache-dir -Ur /app/requirements.txt

RUN addgroup --gid ${GID:-1000} python \
  && adduser --gid ${GID:-1000} --uid ${UID:-1000} --home=/app python \
  && chown -R python:python /app

COPY . /app/
