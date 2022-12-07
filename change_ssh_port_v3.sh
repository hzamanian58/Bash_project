#!/bin/bash
## this application for change default SSH port and disable root user to connect from ssh-service


function config_selinux {
# Configure SELinux to Allow Non-Default SSH Port:
 which $semange &> /dev/null
if [[ $? -ne 0 ]]
then
	echo "install selinux"
	yum install -y policycoreutils-python-utils
else
	echo 'configure selinux for allow new port'
	semanage port -a -t ssh_port_t -p tcp 2222
fi
}

function config_firewall {
# Configure Firewall to Allow Non-Default SSH port:
echo 'remove ssh service'
firewall-cmd --permanent --remove-service=ssh
echo 'add new port to firewall'
firewall-cmd --permanent --add-port=$new_ssh_port/tcp
echo 'firewall reload'
firewall-cmd --reload
echo 'restart ssh service'
systemctl restart sshd.service
}




new_ssh_port=2222


# backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Change Default SSH Port in CentOS
echo 'Change Default SSH Port'
sed -ie 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config

# disable root login
echo 'disable root ssh login and allow to new user'
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
echo "AllowUsers tsmart" >> /etc/ssh/sshd_config

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




function config_selinux {
# Configure SELinux to Allow Non-Default SSH Port:
 which $app &> /dev/null
if [[ $? -ne 0 ]]
then
	echo "install selinux"
	yum install -y policycoreutils-python-utils
else
	echo 'configure selinux for allow new port'
	semanage port -a -t ssh_port_t -p tcp 2222
fi
exit 0
}

function config_firewall {
# Configure Firewall to Allow Non-Default SSH port:
echo 'remove ssh service'
firewall-cmd --permanent --remove-service=ssh
echo 'add new port to firewall'
firewall-cmd --permanent --add-port=$new_ssh_port/tcp
echo 'firewall reload'
firewall-cmd --reload
echo 'restart ssh service'
systemctl restart sshd.service
}






