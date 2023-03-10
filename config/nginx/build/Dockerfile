ARG NGINX_VERSION=1.23.3
ARG HEADERS_MORE_VERSION=v0.34
ARG SECURITY_HEADERS_VERSION=v0.0.11
ARG GEOIP2_VERSION=3.4

FROM nginx:$NGINX_VERSION-alpine-slim

# gcc + make + libc-dev: build dependencies
# git: clone third party modules
# pcre-dev: ngx_http_rewrite_module
# zlib-dev: ngx_http_gzip_module

ARG build_deps="gcc make libc-dev git pcre-dev zlib-dev libmaxminddb-dev"
ARG runtime_deps="pcre zlib libmaxminddb"
RUN apk --update --no-cache add $runtime_deps $build_deps

RUN cd /opt \
    # Download ngx_http_headers_more_filter_module
    && git clone --depth 1 -b $HEADERS_MORE_VERSION --single-branch --branch master https://github.com/openresty/headers-more-nginx-module.git \
    # Download ngx_http_security_headers_module
    && git clone --depth 1 -b $SECURITY_HEADERS_VERSION --single-branch --branch master https://github.com/GetPageSpeed/ngx_security_headers.git \
    # Download ngx_http_geoip2_module
    && git clone --depth 1 -b $GEOIP2_VERSION --single-branch --branch master https://github.com/leev/ngx_http_geoip2_module.git \
    # Download Nginx
    && wget -O - http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar zxfv - \
    && mv ./nginx-$NGINX_VERSION ./nginx \
    # Compile Nginx
    && cd ./nginx \
    && ./configure --with-compat \
    --add-dynamic-module=/opt/headers-more-nginx-module \
    --add-dynamic-module=/opt/ngx_security_headers \
    --add-dynamic-module=/opt/ngx_http_geoip2_module \
    && make modules

RUN mv /opt/nginx/objs/ngx_http_headers_more_filter_module.so /usr/lib/nginx/modules \
    && mv /opt/nginx/objs/ngx_http_security_headers_module.so /usr/lib/nginx/modules \
    && mv /opt/nginx/objs/ngx_http_geoip2_module.so /usr/lib/nginx/modules

RUN chmod -R 644 /usr/lib/nginx/modules/ngx_http_headers_more_filter_module.so
RUN chmod -R 644 /usr/lib/nginx/modules/ngx_http_security_headers_module.so
RUN chmod -R 644 /usr/lib/nginx/modules/ngx_http_geoip2_module.so

# Copy nginx config file
COPY nginx.conf /etc/nginx/nginx.conf
COPY GeoLite2-City.mmdb /opt
COPY GeoLite2-Country.mmdb /opt

WORKDIR /etc/nginx/

COPY ./geoip_update.sh /etc/nginx/geoip_update.sh
RUN chmod +x ./geoip_update.sh
RUN ./geoip_update.sh

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]