#!/bin/bash

echo "----------------------------------------"
echo "v1.0.1 Deploy Script"
echo "----------------------------------------"
echo "[INFO] Running depoly.sh"
echo ""

if [ "${1}" == "naas" ] ; then
  if [ "${2}" == "" ] ; then
    read -p 'Project Name (A-Za-z0-9_): ' projectName
  else
    projectName=${2}
  fi

  if [ "${3}" == "" ] ; then
    read -p 'Project Domain: ' projectDomain
  else
    projectDomain=${3}
  fi
else
  read -p 'Project Name (A-Za-z0-9_): ' projectName
  read -p 'Project Domain: ' projectDomain
fi

if [ -d "$projectName" ]; then
  # Take action if $DIR exists. #
  echo "[INFO] Project already exists"
  exit 1
fi

git clone https://github.com/ame1973/docker-laravel-host-env.git $projectName

# shellcheck disable=SC2164
cd $projectName

pwd

cp docker-compose.example docker-compose.yml

sed -i "s/YOUR_PROJECT_NAME/$projectName/g" docker-compose.yml
sed -i "s/YOUR_PROJECT_DOMAIN/$projectDomain/g" docker-compose.yml

DEFAULT="n"
if [ "${1}" == "naas" ] ; then
  DEFAULT="y"
else
  read -p "Run Laravel at octane? [y/N]: " eOctane
fi

eOctane="${eOctane:-${DEFAULT}}"
if [ "${eOctane}" = "y" ] || [ "${eOctane}" = "Y" ]; then
	sed -i "s/#laravel-octane//g" docker-compose.yml
else
	sed -i "s/#php-fpm//g" docker-compose.yml
fi


# create mysql databases
MYSQL_COMMAND="CREATE DATABASE IF NOT EXISTS ${projectName}_db;"
docker exec docker-laravel-base-env-mysql-1 sh -c "echo '$MYSQL_COMMAND' | mysql -uroot -p'password'"


ip_start=$(find ./ -maxdepth 1 -type d | wc -l)
sed -i "s/PROJECT_IP_START/$ip_start/g" docker-compose.yml

DEFAULT="n"
if [ "${1}" == "naas" ] ; then
  DEFAULT="y"
else
  read -p "Enable Frontend web service? [y/N]: " eFrontend
fi
eFrontend="${eFrontend:-${DEFAULT}}"
if [ "${eFrontend}" = "y" ] || [ "${eFrontend}" = "Y" ] ; then
  if [ "${1}" == "naas" ] ; then
    frontendDomain="marketplace.$projectDomain"
  else
    read -p 'Frontend Domain: ' frontendDomain
  fi
  sed -i "s/YOUR_PROJECT_FRONTEND_DOMAIN/$frontendDomain/g" docker-compose.yml

	sed -i "s/#frontend-service//g" docker-compose.yml
	if [ ! -d "frontend_src" ]; then
    	mkdir "frontend_src"
  fi
fi

DEFAULT="n"
if [ "${1}" == "naas" ] ; then
  DEFAULT="y"
else
  read -p "Enable Web3/Node service? [y/N]: " eFrontend
fi
eFrontend="${eFrontend:-${DEFAULT}}"
if [ "${eFrontend}" = "y" ] || [ "${eFrontend}" = "Y" ] ; then

	sed -i "s/#web3-service//g" docker-compose.yml
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
sed -i "s/YOUR_PROJECT_NAME/$projectName/g" backup_db.sh

cp ./config/script/bash.sh.example bash.sh
sed -i "s/YOUR_PROJECT_NAME/$projectName/g" bash.sh

echo "Done."