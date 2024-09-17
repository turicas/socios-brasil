FROM ubuntu:latest
COPY . /socios-brasil
USER root
ARG mirror=false
ARG censorship=true
ARG import=false
ARG database_url=false
ENV tz=America

RUN apt-get update \
 && ln -snf /usr/share/zoneinfo/$tz /etc/localtime \
 && echo $tz \
 && apt-get install git wget aria2 python3 python3-pip postgresql-client -y \
 && cd /socios-brasil \
 && pip3 install -r requirements.txt \
 && pip3 install rows[cli] \
 && pip3 install rows[postgresql] \
 && pip3 install -U https://github.com/turicas/rows/archive/develop.zip

RUN cd /socios-brasil && ./run.sh --use-mirror --no_censorship
RUN export DATABASE_URL = $database_url \
      && rows pgimport --schema=schema/empresa.csv data/output/empresa.csv.gz $DATABASE_URL empresa \
      && rows pgimport --schema=schema/socio.csv data/output/holding.csv.gz $DATABASE_URL empresa_socia \
      && rows pgimport --schema=schema/socio.csv data/output/socio.csv.gz $DATABASE_URL socio \
      && rows pgimport --schema=schema/cnae-secundaria.csv data/output/cnae-secundaria.csv.gz $DATABASE_URL cnae-secundaria
