#!/bin/bash
## This script is for restore the current directory 
## to the before server to redirect the user to the main page
## when the server is ready.

## Enter your current root directory path here
CURRENT_ROOT_PATH=/var/www/hamid.local/html

## Enter the path to your configuration file here
CONFIG_FILE_PATH=/etc/nginx/conf.d/hamid.local.conf

## Enter your new root directory path here
NEW_SERVER_PATH=/var/www/hamid.local/html2


#pwdesc=$(echo $PWD | sed 's_/_\\/_g')


echo -e "your current path root serve file is: $CURRENT_ROOT_PATH"
echo -e "your config path file is: $CONFIG_FILE_PATH"


sed -ie "s|$NEW_SERVER_PATH|$CURRENT_ROOT_PATH|g" $CONFIG_FILE_PATH
#sed -i 's|/var/www/hamid.local/html|/var/www/hamid.local/html2|g' /etc/nginx/conf.d/hamid.local.conf


nginx -t
nginx -s reload


echo -e "your config path file is: $NEW_SERVER_PATH"
