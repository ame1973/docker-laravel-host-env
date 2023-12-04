FROM php:8.2-fpm-alpine

WORKDIR /var/www/app/

ENV php_conf /usr/local/etc/php-fpm.conf
ENV fpm_conf /usr/local/etc/php-fpm.d/www.conf
ENV php_vars /usr/local/etc/php/conf.d/docker-vars.ini

ENV LUAJIT_LIB=/usr/lib
ENV LUAJIT_INC=/usr/include/luajit-2.1

ARG NGINX_VERSION=1.23.3
ARG HEADERS_MORE_VERSION=v0.34
ARG SECURITY_HEADERS_VERSION=v0.0.11
ARG GEOIP2_VERSION=3.4

ARG WWWUSER=1000
ARG WWWGROUP=1000
ARG WWWUSERNAME=www
ARG TZ=UTC

ENV DEBIAN_FRONTEND=noninteractive

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community gnu-libiconv

# Install system dependencies
ENV COMPOSER_MEMORY_LIMIT='-1'

# INstall nginx + lua and devel kit
RUN apk add --no-cache nginx \
    nginx-mod-http-lua \
    nginx-mod-devel-kit

RUN echo @testing https://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
    echo /etc/apk/respositories && \
    apk update && apk upgrade &&\
    apk add --no-cache \
    bash \
    openssh-client \
    wget \
    supervisor \
    curl \
    libcurl \
    libpq \
    git \
    python3 \
    py3-pip \
    dialog \
    autoconf \
    make \
    libzip-dev \
    bzip2-dev \
    icu-dev \
    tzdata \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libxslt-dev \
    gcc

RUN apk add --no-cache --virtual .sys-deps \
    musl-dev \
    linux-headers \
    augeas-dev \
    libmcrypt-dev \
    python3-dev \
    libffi-dev \
    sqlite-dev \
    imap-dev \
    postgresql-dev \
    lua-resty-core \
    libjpeg-turbo-dev \
    libwebp-dev \
    zlib-dev \
    libxpm-dev \
    libpng \
    libpng-dev && \
  # Install PHP modules
    docker-php-ext-configure gd \
      --enable-gd \
      --with-freetype \
      --with-jpeg && \
    docker-php-ext-install gd && \
     pip install --upgrade pip && \
    docker-php-ext-install pdo_mysql mysqli pdo_sqlite pgsql pdo_pgsql exif intl xsl soap zip && \
    pecl install -o -f xdebug && \
    pecl install -o -f redis && \
    pecl install -o -f mongodb && \
    echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini && \
    echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini && \
    echo "zend_extension=xdebug" > /usr/local/etc/php/conf.d/xdebug.ini && \
    docker-php-source delete && \
    mkdir -p /var/www/app && \
  # Install composer and certbot
    mkdir -p /var/log/supervisor && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --quiet --install-dir=/usr/bin --filename=composer && \
    rm composer-setup.php &&\
  #  pip3 install -U pip && \
    pip3 install -U certbot && \
    mkdir -p /etc/letsencrypt/webrootauth && \
    apk del gcc musl-dev linux-headers libffi-dev augeas-dev python3-dev make autoconf && \
    apk del .sys-deps


SHELL ["/bin/bash", "-eou", "pipefail", "-c"]

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

ADD conf/supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /etc/supervisor/conf.d
RUN chmod -R 777 /var/log/supervisor
RUN chmod -R 777 /var/run
COPY ./laravel_octane.conf /etc/supervisor/conf.d



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
RUN rm -Rf /etc/nginx/nginx.conf
ADD conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx/GeoLite2-City.mmdb /opt
COPY conf/nginx/GeoLite2-Country.mmdb /opt

WORKDIR /etc/nginx/

COPY ./conf/nginx/geoip_update.sh /etc/nginx/geoip_update.sh
RUN chmod +x ./geoip_update.sh
RUN ./geoip_update.sh

WORKDIR /var/www/app/

# Copy our nginx config
ADD conf/nginx/nginx-site.conf /etc/nginx/sites-available/default.conf


# nginx site conf
RUN mkdir -p /etc/nginx/sites-available/ && \
mkdir -p /etc/nginx/sites-enabled/ && \
mkdir -p /etc/nginx/ssl/ && \
rm -Rf /var/www/* && \
mkdir /var/www/html/
ADD conf/nginx/nginx-site.conf /etc/nginx/sites-available/default.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# tweak php-fpm config
RUN echo "cgi.fix_pathinfo=0" > ${php_vars} &&\
    echo "upload_max_filesize = 100M"  >> ${php_vars} &&\
    echo "post_max_size = 100M"  >> ${php_vars} &&\
    echo "variables_order = \"EGPCS\""  >> ${php_vars} && \
    echo "memory_limit = 128M"  >> ${php_vars} && \
    sed -i \
        -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
        -e "s/pm.max_children = 5/pm.max_children = 4/g" \
        -e "s/pm.start_servers = 2/pm.start_servers = 3/g" \
        -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" \
        -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" \
        -e "s/;pm.max_requests = 500/pm.max_requests = 200/g" \
        -e "s/user = www-data/user = nginx/g" \
        -e "s/group = www-data/group = nginx/g" \
        -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
        -e "s/;listen.owner = www-data/listen.owner = nginx/g" \
        -e "s/;listen.group = www-data/listen.group = nginx/g" \
        -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" \
        -e "s/^;clear_env = no$/clear_env = no/" \
        ${fpm_conf}
#    ln -s /etc/php7/php.ini /etc/php7/conf.d/php.ini && \
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini && \
	sed -i \
	    -e "s/;opcache/opcache/g" \
	    -e "s/;zend_extension=opcache/zend_extension=opcache/g" \
            /usr/local/etc/php/php.ini

COPY ./crontab /var/spool/cron/crontabs/root
RUN chmod 0644 /var/spool/cron/crontabs/root
RUN crontab /var/spool/cron/crontabs/root

# Set working directory
WORKDIR /var/www/app

## Copy existing application directory contents
#COPY . /var/www/app

# Copy existing application directory permissions
COPY --chown=$WWWUSERNAME:$WWWUSERNAME . /var/www/app

# Change current user to www
#USER $WWWUSERNAME
# Add Scripts
ADD run.sh /run.sh
RUN chmod 755 /run.sh

# Start service
ENTRYPOINT ["/run.sh"]