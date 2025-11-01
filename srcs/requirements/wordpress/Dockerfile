FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y php8.2-fpm php8.2-mysql curl php8.2-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir /wordpress-download

COPY conf/wp-setup.sh /usr/local/bin/

COPY conf/wordpress.tar.gz /wordpress-download/

RUN chmod +x /usr/local/bin/wp-setup.sh

ENTRYPOINT ["wp-setup.sh"]

EXPOSE 9000

CMD ["php-fpm8.2", "-F"]
