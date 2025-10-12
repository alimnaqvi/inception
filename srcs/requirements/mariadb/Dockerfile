FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/60-custom.cnf

COPY conf/mdb-initialization.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/mdb-initialization.sh

ENTRYPOINT ["mdb-initialization.sh"]

EXPOSE 3306

CMD ["mariadbd", "--user=mysql", "--datadir=/var/lib/mysql"]
