FROM postgres:9.6.1

ARG PG_PASS

ENV POSTGRES_PASSWORD=${SPRING_DATASOURCE_PASSWORD}
ENV POSTGRES_DB hoge
ENV LANG ja_JP.UTF-8

COPY *.sql /docker-entrypoint-initdb.d/

RUN localedef -i ja_JP -c -f UTF-8 -A /usr/share/locale/locale.alias ja_JP.UTF-8

