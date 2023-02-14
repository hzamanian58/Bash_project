#!/bin/bash

SSH_CONF_PATH=/etc/ssh/sshd_config


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
				echo -e "\$martP@ssw0rd\n\$martP@ssw0rd" | passwd --stdin $NEW_USER
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



## this function for config selinux to add SSH NEW PORT 

function config_selinux {
	# Configure SELinux to Allow Non-Default SSH Port:
       	which $semange &> /dev/null
	if [[ $? -ne 0 ]]
	then
		echo "install selinux"
		yum install -y policycoreutils-python-utils
		echo -e "configure selinux for allow $NEW_SSH_PORT"
		semanage port -a -t ssh_port_t -p tcp $NEW_SSH_PORT
	else
		echo -e "configure selinux for allow $NEW_SSH_PORT"
		semanage port -a -t ssh_port_t -p tcp $NEW_SSH_PORT
	fi
}





function config_firewall {
	# Configure Firewall to Allow Non-Default SSH port:
	echo 'remove ssh service'
	firewall-cmd --permanent --remove-service=ssh
	echo 'add new port to firewall'
	firewall-cmd --permanent --add-port=$NEW_SSH_PORT/tcp
	echo 'firewall reload'
	firewall-cmd --reload
	echo 'restart ssh service'
	sshd -t &> error.ssh
	if [[ $? -eq 0 ]]; then
		{
			systemctl restart sshd.service
		}
	else
		cat error.ssh
		set -e
		break
	fi
}


## this application for change default SSH port and disable root user to connect from ssh-service
function change_ssh_default_port {

	read -p 'please enter your new ssh port number: ' NEW_SSH_PORT
	echo -e "your port input is: $NEW_SSH_PORT"

	# backup sshd_config
	cp $SSH_CONF_PATH $SSH_CONF_PATH.bak
	# Change Default SSH Port in CentOS
	echo 'Change Default SSH Port'
	sed -ie "s/#Port 22/Port $NEW_SSH_PORT/g" /etc/ssh/sshd_config

	# disable root login
	echo -e "disable root login via ssh connection and privilage to $NEW_USER"
 
	sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' $SSH_CONF_PATH
        sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/g' $SSH_CONF_PATH
        sed -i 's/#LoginGraceTime 2m/LoginGraceTime 20/g' $SSH_CONF_PATH
        sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' $SSH_CONF_PATH
        sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/g' $SSH_CONF_PATH
        sed -i 's/#KerberosAuthentication no/KerberosAuthentication no/g' $SSH_CONF_PATH
        sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' $SSH_CONF_PATH
        sed -i 's/X11Forwarding yes/X11Forwarding no/g' $SSH_CONF_PATH
        sed -i 's/#PermitUserEnvironment no/PermitUserEnvironment no/g' $SSH_CONF_PATH
        sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/g' $SSH_CONF_PATH
        sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' $SSH_CONF_PATH
        sed -i 's/#PermitTunnel no/PermitTunnel no/g' $SSH_CONF_PATH


        echo "AllowUsers $NEW_USER" >> $SSH_CONF_PATH
        sshd -t
        if [[ $? -eq 0 ]]; then
                {
                        config_selinux
                        config_firewall
                }
        else
                set -e
                exit 1
        fi
}




# selection for which program to runa

select action in create_new_user change_ssh_default_port exit; do
case $action in
        "exit")
                exit 0
                ;;
        "create_new_user")
             create_new_user
             ;;
        "change_ssh_default_port")
             change_ssh_default_port
             ;;
        esac
done
