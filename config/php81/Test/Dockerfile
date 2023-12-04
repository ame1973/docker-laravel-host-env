FROM php:8.1-fpm-alpine

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
        bash\
        gcc \
        g++ \
        libffi-dev \
        openssl \
        openssl-dev \
        libtool \
        libc-dev \
        make \
        autoconf \
        libevent \
        zip \
        unzip \
        curl \
        wget \
        nodejs \
        libxml2-dev \
        oniguruma-dev \
        libzip-dev \
        libpng-dev \
        openssh-client \
        supervisor \
        libcurl \
        libpq \
        git \
        dialog \
        bzip2-dev \
        icu-dev \
        tzdata \
        libjpeg-turbo-dev \
        freetype-dev \
        libxslt-dev \
        gmp-dev \
        imagemagick \
        imagemagick-libs \
        imagemagick-dev \
        mysql-client \
        libmemcached-dev \
        libmemcached


# Install soap extention
RUN docker-php-ext-install soap

# Install the mbstring
RUN docker-php-ext-install mbstring

# Install for image manipulation
RUN docker-php-ext-install exif

# Install the PHP pcntl extention
RUN docker-php-ext-install pcntl

# Install the PHP zip extention
RUN docker-php-ext-install zip

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo_mysql

# Install the PHP pdo_pgsql extention
#RUN docker-php-ext-install pdo_pgsql

# Install the PHP bcmath extension
RUN docker-php-ext-install bcmath

# Install the PHP intl extention
RUN docker-php-ext-install intl

# Install the PHP gmp extention
RUN docker-php-ext-install gmp

#####################################
# PHPRedis:
#####################################
RUN pecl install redis && docker-php-ext-enable redis

#####################################
# Imagick:
#####################################

RUN pecl install imagick && \
    docker-php-ext-enable imagick

#####################################
# GD:
#####################################

# Install the PHP gd library
RUN docker-php-ext-install gd && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd

#####################################
# PHP Memcached:
#####################################

# Install the php memcached extension
RUN pecl install memcached && docker-php-ext-enable memcached

#####################################
# PHP Swoole:
#####################################
RUN pecl install swoole && docker-php-ext-enable swoole.so

# Get latest Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
