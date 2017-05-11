FROM alpine

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk add --update \
            g++ \
            make \
            wget

ARG NGINX_VERSION=1.11.13

# download nginx src
RUN \
    mkdir -p /etc/nginx/modules && \
    cd /etc/nginx && \
    wget --no-check-certificate -O nginx.tar.gz http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar zxvf nginx.tar.gz --strip-components 1 && \
    rm nginx.tar.gz

COPY . /etc/nginx/modules/nginx-statsd

# build nginx
RUN \
    ls -al /etc/nginx/modules && \
    cd /etc/nginx && \
    ./configure \
                --with-compat \
                --without-http_gzip_module \
                --without-http_rewrite_module \
                --add-dynamic-module=/etc/nginx/modules/nginx-statsd && \
    make -B modules

VOLUME /export

CMD ["cp", "/etc/nginx/objs/ngx_http_statsd_module.so", "/export"]
