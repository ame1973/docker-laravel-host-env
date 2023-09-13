FROM webdevops/php-nginx:8.1-alpine
COPY ./src /app

RUN docker-service enable cron

RUN docker-cronjob '* * * * * /usr/local/bin/php /var/www/app/artisan schedule:run >> /dev/null 2>&1'

RUN composer install -d /app

