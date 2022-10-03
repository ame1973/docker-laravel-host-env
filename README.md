# Docker host Laravel

- **Docker**

- **Docker Compose**

- **traefik**

- **portainer**

- **php:8.1-fpm**


> this env base on portainer and traefik. please follow up this repo to set the server env.
> 
> [ame1973/docker-traefik-portainer](https://github.com/ame1973/docker-traefik-portainer)

## Optional services

- redis

- meilisearch

## host project

1. change this project folder name to your own project name.

2. clone your laravel project to `./src`.

3. run script

```bash
./depoly.sh
```

4. enter your project name and project domain.

or

**change docker-compose.yml**

```
- "traefik.http.routers.YOUR_PROJECT.rule=Host(`YOUR_PROJECT_DOMAIN.com`)"
- "traefik.http.routers.YOUR_PROJECT.entrypoints=websecure"
```

```
docker-compose up -d
```

**.env mysql**

```
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=password
```

## Backup SQL Database

run `./backup_db.sh` . the .sql file will output to ./backup/mysql/laravel_{time}.sql

## Reset

remove images

rm -rf volumes

## config Laravel

`composer` and `php artisan` command need go to php containers shell run.

## Issue

- ERROR: no matching manifest for linux/arm64/v8 in the manifest list entries

change `mysql:8.0.28` to `mysql/mysql-server:8.0.28`
