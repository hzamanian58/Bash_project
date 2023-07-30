#!/bin/bash

## This script is used to temporarily change the configuration of the web server settings

##  Enter the path of the web server configuration files
PATH_CONF=/etc/nginx/conf.d

## Enter the name of the web server config file
FILE=dev.kodoumo.ir.conf

## change main config file to temp
mv $PATH_CONF/$FILE $PATH_CONF/$FILE.temp

## Copy the static page configuration file to the root path
cp $PATH_CONF/html/$FILE.html $PATH_CONF/

## Rename the copied file
mv $PATH_CONF/$FILE.html $PATH_CONF/$FILE

nginx -t

if [[ $? -eq 0 ]]
then
	nginx -s reload
else
	echo "An error has occurred "
fi

