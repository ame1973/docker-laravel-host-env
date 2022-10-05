#!/bin/bash

read -p 'Project Name (A-Za-z0-9_): ' projectName
read -p 'Project Domain: ' projectDomain

cp docker-compose.example docker-compose.yml

sed -i "s/YOUR_PROJECT_NAME/$projectName/g" docker-compose.yml
sed -i "s/YOUR_PROJECT_DOMAIN.com/$projectDomain/g" docker-compose.yml

DEFAULT="n"
read -p "Run Laravel at octane? [y/N]: " eOctane
eOctane="${eOctane:-${DEFAULT}}"
if [ "${eOctane}" = "y" ] || [ "${eOctane}" = "Y" ]; then
	sed -i "s/#laravel-octane//g" docker-compose.yml
else
	sed -i "s/#php-fpm//g" docker-compose.yml
fi

MYSQL_COMMAND="create database ${projectName}_db;"
docker exec docker-laravel-base-env-mysql-1 sh -c "echo '$MYSQL_COMMAND' | mysql -uroot -p'password'"

FILE=./src/.env.example
if test -f "$FILE"; then
    cp ./src/.env.example ./src/.env
	sed -i "s/DB_HOST=.*/DB_HOST=mysql/g" ./src/.env
	sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=password/g" ./src/.env
	sed -i "s/APP_NAME=.*/APP_NAME=$projectName/g" ./src/.env
	sed -i "s/APP_ENV=.*/APP_ENV=production/g" ./src/.env
	sed -i "s/APP_URL=.*/APP_URL=https:\/\/$projectDomain/g" ./src/.env
fi

cp ./backup/backup_db.sh.example backup_db.sh
sed -i "s/YOUR_PROJECT_NAME/$projectName/g" backup_db.sh

cp ./config/script/bash.sh.example bash.sh
sed -i "s/YOUR_PROJECT_NAME/$projectName/g" bash.sh

echo "Done."