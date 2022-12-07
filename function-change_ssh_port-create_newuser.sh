#!/bin/bash
## this application for change default SSH port and disable root user to connect from ssh-service



function create_new_user {
	echo "now run Create new user"
## this application for create new user (test)
echo "this application for create new user"
user=test
# create test user
echo "create user"
sudo adduser $user
echo "change usermode"
usermod -aG wheel $user
echo 'Are you change password automatically or manual?'
select action in Auto manual exit; do
case $action in
	Auto)
		echo -e "test\ntest" | passwd --stdin $user
		;;
	manual)
		passwd tsmart
		;;
	exit)
		exit 0
		;;
	esac
	
done

}




function change_ssh_default_port {
	echo "now run Change ssh default port"
# Change Default SSH Port in CentOS
echo 'add new ssh port to ssh config'
echo "Port 2222" >> /etc/ssh/sshd_config

# disable root login
echo 'disable root ssh login and allow to new user'
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
echo "AllowUsers tsmart" >> /etc/ssh/sshd_config

# Configure SELinux to Allow Non-Default SSH Port:
echo "install selinux"
yum install -y policycoreutils-python-utils
echo 'configure selinux for allow new port'
semanage port -a -t ssh_port_t -p tcp 2222

# Configure Firewall to Allow Non-Default SSH port:
echo 'remove ssh service'
firewall-cmd --permanent --remove-service=ssh
echo 'add new port to firewall'
firewall-cmd --permanent --add-port=2222/tcp
echo 'firewall reload'
firewall-cmd --reload
echo 'restart ssh service'
systemctl restart sshd.service

}


function install_app {
	echo "now run install APP"

}

# selection for which program to run
select action in create_new_user change_ssh_default_port install_app exit; do
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
	"install_app")
	     install_app
	     ;;
	esac
done
