#!/bin/bash

# Config default, customize in config-include.sh:
export AEGIR_SITE=aegir.web
export AEGIR_FRONTEND_URL=aegir.web
export AEGIR_EMAIL=aegir@aegir.web
export AEGIR_DB_PASSWORD=123
export AEGIR_VERSION=6.x-1.9
export MYSQL_ROOT_PW=CHANGEME
export POSTFIX_DOMAIN=aegir.web
export POSTFIX_MAILNAME=aegir.web

export IMAGE_NAME=___you___/aegir
export INSTANCE_NAME=aegir

# change this if you want to mount volumes in some other place
export MOUNT_POINT=/var/docker/$INSTANCE_NAME

if [ -f config-include.sh ]; then
  source config-include.sh
fi

docker run \
  --detach=true \
  -v $MOUNT_POINT/files:/var/aegir \
  -v $MOUNT_POINT/data:/var/lib/mysql \
  -e AEGIR_SITE=$AEGIR_SITE \
  -e AEGIR_FRONTEND_URL=$AEGIR_FRONTEND_URL \
  -e AEGIR_EMAIL=$AEGIR_EMAIL \
  -e AEGIR_DB_PASSWORD=$AEGIR_DB_PASSWORD \
  -e AEGIR_VERSION=$AEGIR_VERSION \
  -e MYSQL_ROOT_PW=$MYSQL_ROOT_PW \
  -e POSTFIX_MAILNAME=$POSTFIX_MAILNAME \
  -e POSTFIX_DESTINATION=$POSTFIX_DOMAIN \
  -p 8280:80 \
  -h $AEGIR_SITE \
  --name $INSTANCE_NAME \
  $IMAGE_NAME
