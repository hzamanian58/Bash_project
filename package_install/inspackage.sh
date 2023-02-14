#!/bin/bash

# to recogonize OS distribution (CentOS / Ubuntu)

declare os=$(hostnamectl | grep -iw 'Operating System:' | awk '{print $3}')
#os="Ubuntu"



# install package(s) if OSrelease is CentOS

if [[ $os == "CentOS" ]]; then
	echo "your distribution is $os"
# decalre varables for testing if update and epel-release is installed or not
update=0
epel=0

# resolv Appstream repository
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

  for app in $@
  do
		  which $app &> /dev/null
		  if [[ $? -eq 0 ]]
		  then
			  echo $app "is installed on your system"
		  elif [[ $update -eq 0 && $epel -eq 0 ]]
		  then
			  # to save current dns (/etc/resolv.conf) to file
			  egrep "nameserver [0-9]*\." /etc/resolv.conf > currentdns.txt
		  	  echo "default dns is: " 
		  	  cat /etc/resolv.conf
		  	  # change DNS address to Shekan..
		  	  echo "changing DNS Address..."
		  	  #echo -e "nameserver 178.22.122.100\nnameserver 185.51.200.2" > /etc/resolv.conf
		  	  sudo sed -i 's/nameserver [[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*/nameserver 178.22.122.100/' /etc/resolv.conf
			  cat /etc/resolv.conf

			  # update repository and install Extra Packages for Enterprise Linux

			  sudo dnf -y update
			  sudo dnf -y install epel-release
			  update=1
			  epel=1

			  # install first package
			  sudo dnf -y install $app
		  else
			  # install secend package to end packages
			  sudo dnf -y install $app
		  fi
	  done
echo "DNS back to default ..."

# to search and replace any ip address that set by nameserver and with blank line
sed -i 's/nameserver [[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*//' /etc/resolv.conf
# to append old dns write back to dns setting
cat currentdns.txt >> /etc/resolv.conf
echo "dns default ..."
cat /etc/resolv.conf


  
  # install package(s) if OSrelease is Ubuntu
elif [[ $os == *"Ubuntu"* ]]
then
	echo "you are in $os distribution"
	for app in $@
	do
		which $app
		if [[ $? -eq 0 ]]
		then
			echo $app "is installed on your system"
		elif [[ $update -eq 0 ]]
		then
			sudo app-get -y update
			sudo apt-get -y install $app
		else
			sudo apt-get -y install $app
		fi
	done
else
	echo "your distribtion is not recogonized"
fi
