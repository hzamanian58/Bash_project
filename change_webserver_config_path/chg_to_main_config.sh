#!/bin/bash

## This script is used to temporarily change the configuration of the web server settings

##  Enter the path of the web server configuration files
PATH_CONF=/etc/nginx/conf.d

## Enter the name of the web server config file
FILE=dev.kodoumo.ir.conf


## Delete the temporary file
rm -rf $PATH_CONF/$FILE


## Returning the original configuration file
mv $PATH_CONF/$FILE.temp $PATH_CONF/$FILE


nginx -t

if [[ $? -eq 0 ]]
then
	nginx -s reload
else
	echo "An error has occurred "
fi

