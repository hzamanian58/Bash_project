#!/bin/bash
## this function for define new user
function create_new_user {
	read -p 'please enter your new user: ' NEW_USER
        echo "now run Create $NEW_USER user"
	## this application for create new user
	echo "this application for create new user: $NEW_USER"
	# create new user
	echo "create user: $NEW_USER"
	sudo adduser $NEW_USER
	echo "change usermode"
	usermod -aG wheel $NEW_USER
	echo 'Are you change password automatically or manual?'
	select action in Auto manual exit; do
		case $action in
			Auto)
				echo -e "P@ssw0rd\nP@ssw0rd" | passwd --stdin $NEW_USER
				break
				;;
			manual)
				passwd $NEW_USER
				break
				;;
			exit)
				break
				;;
		esac
	done
}