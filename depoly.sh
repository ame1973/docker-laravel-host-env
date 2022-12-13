#!/bin/bash

read -p 'Project Name (A-Za-z0-9_): ' projectName
read -p 'Project Domain: ' projectDomain

if [ "${1}" == "clone" ] ; then
  git clone https://github.com/ame1973/docker-laravel-host-env.git $projectName
  cd $projectName
  pwd
fi

cp docker-compose.example docker-compose.yml

sed -i '' "s/YOUR_PROJECT_NAME/$projectName/g" docker-compose.yml
sed -i '' "s/YOUR_PROJECT_DOMAIN/$projectDomain/g" docker-compose.yml

DEFAULT="n"
read -p "Run Laravel at octane? [y/N]: " eOctane
eOctane="${eOctane:-${DEFAULT}}"
if [ "${eOctane}" = "y" ] || [ "${eOctane}" = "Y" ]; then
	sed -i '' "s/#laravel-octane//g" docker-compose.yml
else
	sed -i '' "s/#php-fpm//g" docker-compose.yml
fi

MYSQL_COMMAND="create database ${projectName}_db;"
docker exec docker-laravel-base-env-mysql-1 sh -c "echo '$MYSQL_COMMAND' | mysql -uroot -p'password'"

read -p "Enable Frontend web service? [y/N]: " eFrontend
eFrontend="${eFrontend:-${DEFAULT}}"
if [ "${eFrontend}" = "y" ] || [ "${eFrontend}" = "Y" ] ; then
  read -p 'Frontend Domain: ' frontendDomain
  sed -i '' "s/YOUR_PROJECT_FRONTEND_DOMAIN/$frontendDomain/g" docker-compose.yml

	sed -i '' "s/#frontend-service//g" docker-compose.yml
	if [ ! -d "frontend_src" ]; then
    	mkdir "frontend_src"
  fi
fi

read -p "Enable Web3/Node service? [y/N]: " eFrontend
eFrontend="${eFrontend:-${DEFAULT}}"
if [ "${eFrontend}" = "y" ] || [ "${eFrontend}" = "Y" ] ; then

	sed -i '' "s/#web3-service//g" docker-compose.yml
	if [ ! -d "web3_src" ]; then
    	mkdir "web3_src"
  fi
fi

if [ ! -d "src" ]; then
    mkdir "src"
fi

#FILE=./src/.env.example
#if test -f "$FILE"; then
#  cp ./src/.env.example ./src/.env
#	sed -i "s/DB_HOST=.*/DB_HOST=mysql/g" ./src/.env
#	sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=password/g" ./src/.env
#	sed -i "s/APP_NAME=.*/APP_NAME=$projectName/g" ./src/.env
#	sed -i "s/APP_ENV=.*/APP_ENV=production/g" ./src/.env
#	sed -i "s/APP_URL=.*/APP_URL=https:\/\/$projectDomain/g" ./src/.env
#fi

cp ./backup/backup_db.sh.example backup_db.sh
sed -i '' "s/YOUR_PROJECT_NAME/$projectName/g" backup_db.sh

cp ./config/script/bash.sh.example bash.sh
sed -i '' "s/YOUR_PROJECT_NAME/$projectName/g" bash.sh

echo "Done."