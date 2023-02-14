#!/bin/bash

## This script is for redirecting the current directory
## to the new server to redirect the user to the new page
## when the server is updated. 

## Enter your current root directory path here
CURRENT_ROOT_PATH=/var/www/hamid.local/html;

## Enter The main path of the block server
MAIN_SRV_BLK_PATH=/var/www/hamid.local

## Enter the path to your configuration file here
CONFIG_FILE_PATH=/etc/nginx/conf.d/hamid.local.conf

## Enter your new root directory path here
NEW_SERVER_PATH=/var/www/hamid.local/html2;


echo -e "your current path root serve file is: $CURRENT_ROOT_PATH"
echo -e "your config path file is: $CONFIG_FILE_PATH"

## Change your current root directory with new
sed -ie "s|$CURRENT_ROOT_PATH|$NEW_SERVER_PATH|g" $CONFIG_FILE_PATH
#sed -i 's|/var/www/hamid.local/html|/var/www/hamid.local/html2|g' /etc/nginx/conf.d/hamid.local.conf

# update your server’s SELinux security contexts
## This chcon context update will allow your custom document root to be served as HTTP content:
chcon -vR system_u:object_r:httpd_sys_content_t:s0 $MAIN_SRV_BLK_PATH

nginx -t
nginx -s reload

echo -e "your config path file is: $NEW_SERVER_PATH"
