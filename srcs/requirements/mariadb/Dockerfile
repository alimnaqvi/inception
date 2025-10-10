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
    # rm -rf /var/lib/mysql && \
    # mariadb-install-db --user=mysql --datadir='/var/lib/mysql'

# RUN echo "hello world from Dockerfile" > /var/lib/mysql/hello.txt

# RUN --mount=type=secret,id=db_root_password,env=MARIADB_ROOT_PASSWORD \
#     --mount=type=secret,id=db_password,env=MARIADB_PASSWORD \
#     mdb-initialization.sh

# RUN --mount=type=secret,id=db_root_password \
#     --mount=type=secret,id=db_password \
#     export MARIADB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password) && \
#     export MARIADB_PASSWORD=$(cat /run/secrets/db_password)

ENTRYPOINT ["mdb-initialization.sh"]

EXPOSE 3306

CMD ["mariadbd-safe"]
