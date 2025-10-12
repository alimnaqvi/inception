FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/60-custom.cnf

COPY conf/mdb-initialization.sh /usr/local/bin/

ARG MARIADB_DATABASE
ARG MARIADB_USER
ENV MARIADB_DATABASE=${MARIADB_DATABASE}
ENV MARIADB_USER=${MARIADB_USER}

RUN chmod +x /usr/local/bin/mdb-initialization.sh

ENTRYPOINT ["mdb-initialization.sh"]

EXPOSE 3306

CMD ["mariadbd", "--user=mysql", "--datadir=/var/lib/mysql"]
