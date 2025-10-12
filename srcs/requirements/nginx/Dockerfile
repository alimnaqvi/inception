FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/sites-available/default

COPY conf/nginx-setup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/nginx-setup.sh

ENTRYPOINT ["nginx-setup.sh"]

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
