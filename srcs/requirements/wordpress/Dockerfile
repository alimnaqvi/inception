FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y php8.2-fpm curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /wordpress-download

COPY conf/wp-setup.sh /usr/local/bin/

COPY conf/wordpress.tar.gz /wordpress-download/

ARG MARIADB_DATABASE
ARG MARIADB_USER
ARG WORDPRESS_VERSION
ARG WORDPRESS_SHA1
ENV MARIADB_DATABASE=${MARIADB_DATABASE}
ENV MARIADB_USER=${MARIADB_USER}
ENV WORDPRESS_VERSION=${WORDPRESS_VERSION}
ENV WORDPRESS_SHA1=${WORDPRESS_SHA1}

RUN chmod +x /usr/local/bin/wp-setup.sh

ENTRYPOINT ["wp-setup.sh"]

EXPOSE 9000

CMD ["php-fpm8.2", "-F"]
