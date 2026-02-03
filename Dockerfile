FROM python:3.11-slim-bookworm

ENV PYTHONUNBUFFERED 1
ARG DEV_BUILD
WORKDIR /app

RUN apt update \
  && apt install -y aria2 build-essential make python3-dev wget \
  && echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && wget --quiet -O /etc/apt/trusted.gpg.d/postgres.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  && apt update \
  && apt install -y postgresql-client-17 libpq-dev \
  && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/
RUN pip install --no-cache-dir -U pip \
  && pip install --no-cache-dir -Ur /app/requirements.txt

RUN addgroup --gid ${GID:-1000} python \
  && adduser --gid ${GID:-1000} --uid ${UID:-1000} --home=/app python \
  && chown -R python:python /app

COPY . /app/
