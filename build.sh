#!/bin/bash

cd ./config
cd ./php81
docker buildx build --platform linux/arm64 -t ame1973/php-81-laravel:latest . --push

cd ./laravel_octane
docker buildx build --platform linux/arm64 -t ame1973/php-81-laravel-supervisor:latest . --push

cd ../../php82
docker buildx build --platform linux/arm64 -t ame1973/php-82-laravel:latest . --push

cd ./laravel_octane
docker buildx build --platform linux/arm64 -t ame1973/php-82-laravel-supervisor:latest . --push