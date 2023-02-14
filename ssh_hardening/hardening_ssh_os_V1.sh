#!/bin/bash

## this application for change default SSH port and disable etc/ssh/sshd_configfrom ssh-service


SSH_NEW_PORT=22022
NEW_USER=tsmart

SFTP_USER=tsmart_web
PATH_DIRECTORY_SFTP="/home/$SFTP_USER/"

## this function for config selinux to add SSH NEW PORT

function config_selinux {
        # Configure SELinux to Allow Non-Default SSH Port:
        which $semange &> /dev/null
        if [[ $? -ne 0 ]]
        then
                echo "install selinux"
                yum install -y policycoreutils-python-utils
                echo -e 'configure selinux for allow $SSH_NEW_PORT'
                semanage port -a -t ssh_port_t -p tcp $SSH_NEW_PORT
        else
                echo -e 'configure selinux for allow $SSH_NEW_PORT'
                semanage port -a -t ssh_port_t -p tcp $SSH_NEW_PORT
        fi
}





function config_firewall {
        # Configure Firewall to Allow Non-Default SSH port:
        echo 'remove ssh service'
        firewall-cmd --permanent --remove-service=ssh
        echo 'add new port to firewall'
        firewall-cmd --permanent --add-port=$SSH_NEW_PORT/tcp
        echo 'firewall reload'
        firewall-cmd --reload
        echo 'restart ssh service'
        systemctl restart sshd.service
}




function ssh_hardening {
        # backup sshd_config
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.back
        # Change Default SSH Port in CentOS
        echo 'Change Default SSH Port'
        sed -ie "s/#Port 22/Port $SSH_NEW_PORT/g" /etc/ssh/sshd_config
        # disable root login
        echo -e "disable root login via ssh connection and privilage to $NEW_USER"
        sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
	sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
	sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/g' /etc/ssh/sshd_config
	sed -i 's/#LoginGraceTime 2m/LoginGraceTime 20/g' /etc/ssh/sshd_config
	sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
	sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config
	sed -i 's/#KerberosAuthentication no/KerberosAuthentication no/g' /etc/ssh/sshd_config
	sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
	sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
	sed -i 's/#PermitUserEnvironment no/PermitUserEnvironment no/g' /etc/ssh/sshd_config
	sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/g' /etc/ssh/sshd_config
	sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config
	sed -i 's/#PermitTunnel no/PermitTunnel no/g' /etc/ssh/sshd_config


#        echo "AllowUsers tsmart" >> /etc/ssh/sshd_config
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


function config_sftp {
	echo -e "Match User $SFTP_USER
      	ForceCommand internal-sftp
	ChrootDirectory $PATH_DIRECTORY_SFTP" >> /etc/ssh/sshd_config

}

select action in harden_ssh create_sftp exit; do
	case $action in
		"exit")
			exit 0
			;;
		harden_ssh)
			echo "ssh_hardening is running ... "
			ssh_hardening
			if [[ $? -eq 0 ]]; then
				echo "everything is OK"
			else
				echo "something is wrong!!!!"
			fi
			;;
		create_sftp)
			config_sftp
			;;
	esac
done

