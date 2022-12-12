FROM php:8.1-fpm

WORKDIR /var/www/app/

ARG WWWUSER=1000
ARG WWWGROUP=1000
ARG WWWUSERNAME=www
ARG TZ=UTC

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-eou", "pipefail", "-c"]

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

# Install system dependencies
ENV COMPOSER_MEMORY_LIMIT='-1'

RUN apt-get update && \
    apt-get install -y --force-yes --no-install-recommends \
        libonig-dev \
        libmemcached-dev \
        libz-dev \
        libzip-dev \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        openssh-server \
        libmagickwand-dev \
        git \
        cron \
        nano \
        libxml2-dev \
        libreadline-dev \
        libgmp-dev \
        #mariadb-client \
        default-mysql-client \
        unzip

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

# Install supervisor
RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests supervisor
#RUN touch /var/run/supervisor.sock
#RUN chmod 777 /var/run/supervisor.sock
#RUN unlink /var/run/supervisor.sock
RUN mkdir -p /var/log/supervisor
RUN chmod -R 777 /var/log/supervisor
RUN chmod -R 777 /var/run
COPY laravel_octane/laravel_octane.conf /etc/supervisor/conf.d

# Clear cache
RUN apt-get clean \
    && docker-php-source delete \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm /var/log/lastlog /var/log/faillog

# Create system user to run Composer and Artisan Commands
RUN groupadd --force -g $WWWGROUP $WWWUSERNAME \
    && useradd -ms /bin/bash --no-log-init --no-user-group -g $WWWGROUP -u $WWWUSER $WWWUSERNAME

# Set working directory
WORKDIR /var/www/app

# Copy existing application directory contents
COPY . /var/www/app

# Copy existing application directory permissions
COPY --chown=$WWWUSERNAME:$WWWUSERNAME . /var/www/app

# Change current user to www
USER $WWWUSERNAME

COPY ./laravel_octane/crontab /var/spool/cron/crontabs/root
RUN chmod 0644 /var/spool/cron/crontabs/root
RUN crontab /var/spool/cron/crontabs/root

COPY ./laravel_octane/entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]

# Start service
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]