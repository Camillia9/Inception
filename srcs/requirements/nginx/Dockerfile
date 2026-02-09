FROM alpine:3.12

RUN apk update && apk upgrade && apk add --no-cache \
    openssl \
    nginx

RUN rm -f /etc/nginx/http.d/default.conf

COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY tools/setup_nginx.sh /setup_nginx.sh

RUN chmod +x /setup_nginx.sh

EXPOSE 443

ENTRYPOINT ["sh", "/setup_nginx.sh"]