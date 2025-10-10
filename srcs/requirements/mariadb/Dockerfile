FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    # service mariadb start && \
    # mariadb-install-db --user=mysql --datadir=/var/lib/mysql && \
    # sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/60-custom.cnf

COPY conf/docker-entrypoint.sh /usr/local/bin/

ARG MARIADB_DATABASE
ARG MARIADB_USER
ENV MARIADB_DATABASE=${MARIADB_DATABASE}
ENV MARIADB_USER=${MARIADB_USER}

# ENV MARIADB_DATABASE=${MARIADB_DATABASE} MARIADB_USER=${MARIADB_USER}

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN --mount=type=secret,id=db_root_password,env=MARIADB_ROOT_PASSWORD \
    --mount=type=secret,id=db_password,env=MARIADB_PASSWORD \
    docker-entrypoint.sh
    # MARIADB_DATABASE=${MARIADB_DATABASE} MARIADB_USER=${MARIADB_USER} \

# ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306

CMD ["mariadbd-safe"]
