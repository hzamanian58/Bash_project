#!/bin/bash


## this function for define new user
function create_sftp {
	DOC_ROOT_PATH=/var/www/Your_Domain


	read -p 'please enter your new user: ' NEW_USER
        echo "now run Create $NEW_USER user"
	## this application for create new user
	echo "this application for create new user: $NEW_USER"
	# create new user
	echo "create user: $NEW_USER"
	sudo useradd $NEW_USER
	echo 'create your password:'
	passwd $NEW_USER
	# create new group "webadmin"  and new user "webadmin1" and adding to "webadmin" group
	groupadd webadmin
	usermod -aG webadmin $NEW_USER
	# restrict "NEW_USER" user to not login

	usermod -s /sbin/nologin $NEW_USER


	
	chown -R $WEB_SERVER:webadmin $DOC_ROOT_PATH/html/

	# set stickybit for same folder
	chmod -R 2775 $DOC_ROOT_PATH/html/
	
	
	## config for sshd_config ##
	
	# backup sshd_config
	cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
cat << EOF >> /etc/ssh/sshd_config
	Match Group webadmin
	ForceCommand internal-sftp
	ChrootDirectory $DOC_ROOT_PATH
EOF
	sshd -t
	systemctl restart sshd
	exit 0
}

echo "enter your web server: "
select action in nginx apache other exit; do
	case $action in
		"exit")
			exit 0
			;;
		"nginx")
			WEB_SERVER=nginx
			create_sftp
			;;
		"apache")
			WEB_SERVER=apache
			create_sftp
			;;
		"other")
			echo "your server is not defined"
			exit 1
			;;
	esac
done
