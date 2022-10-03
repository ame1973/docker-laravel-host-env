#!/bin/bash

read -p 'Project Name: ' projectName
read -p 'Project Domain: ' projectDomain

cp docker-compose.example docker-compose.yml

sed -i "s/YOUR_PROJECT_NAME/$projectName/g" docker-compose.yml
sed -i "s/YOUR_PROJECT_DOMAIN.com/$projectDomain/g" docker-compose.yml

DEFAULT="y"
read -p "Enable redis? [Y/n]: " eRedis
eRedis="${eRedis:-${DEFAULT}}"
if [ "${eRedis}" = "y" ] || [ "${eRedis}" = "Y" ]; then
	sed -i "s/#redis//g" docker-compose.yml
fi

read -p "Enable meilisearch? [Y/n]: " eMeilisearch
eMeilisearch="${eMeilisearch:-${DEFAULT}}"
if [ "${eMeilisearch}" = "y" ] || [ "${eMeilisearch}" = "Y" ] ; then
	sed -i "s/#meilisearch//g" docker-compose.yml
fi

DEFAULT="n"
read -p "Run Laravel at octane? [y/N]: " eOctane
eOctane="${eOctane:-${DEFAULT}}"
if [ "${eOctane}" = "y" ] || [ "${eOctane}" = "Y" ]; then
	sed -i "s/#laravel-octane//g" docker-compose.yml
else
	sed -i "s/#php-fpm//g" docker-compose.yml
fi

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