#!/bin/bash

# -------------------------------------
# common functions
# -------------------------------------

# check package manager
# return: apt or yum
function get_package_manager
{
	local package_manager=apt
    if [ -x "$(command -v yum)" ]; then
        package_manager=yum	
    fi
	# return
	echo "$package_manager"
}

# Check Tools Exist
# return: true or false
function check_tool_exist
{
	local is_exist=false
	if [ -x "$(command -v $1)" ]; then
		is_exist=true
	fi
	echo "$is_exist"
}

# -------------------------------------
# my functions
# -------------------------------------

# install docker from repo
function install_docker_from_repo
{
	if [ "$package_manager" = yum ]; then
		# SET UP THE REPOSITORY
		sudo yum install -y yum-utils \
			device-mapper-persistent-data \
			lvm2
		sudo yum-config-manager \
			--add-repo \
			https://download.docker.com/linux/centos/docker-ce.repo
			
		# INSTALL DOCKER ENGINE - COMMUNITY
		sudo yum install -y docker-ce docker-ce-cli containerd.io
	fi
	
	if [ "$package_manager" = apt ]; then
		# SET UP THE REPOSITORY
		# 1. Update the apt package index
		sudo apt-get update
		# 2. Install packages to allow apt to use a repository over HTTPS
		sudo apt-get install -y \
			apt-transport-https \
			ca-certificates \
			curl \
			gnupg2 \
			software-properties-common
		# 3. Add Docker’s official GPG key
		curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
		# 4. Use the following command to set up the stable repository. To add the nightly or test repository,
		sudo add-apt-repository \
		   "deb [arch=amd64] https://download.docker.com/linux/debian \
		   $(lsb_release -cs) \
		   stable"
		sudo apt-key fingerprint 0EBFCD88
		# INSTALL DOCKER ENGINE - COMMUNITY
		# 1. Update the apt package index.
		sudo apt-get update
		# 2. Install the latest version of Docker Engine - Community
		sudo apt-get install -y docker-ce docker-ce-cli containerd.io
	fi
	sudo systemctl enable docker
}



# -------------------------------------
# main
# -------------------------------------

# prepare: check package manager
package_manager=$(get_package_manager)
echo -e "\n\n Package manager is $package_manager ! \n\n"


# installation
tool_name=docker
is_exist=$(check_tool_exist $tool_name)
if [ "$is_exist" = true ]; then
	echo -e "\n\n $tool_name tool is exist ! \n\n"
	echo -n "$(docker --version) is installed. Do you want to remove it? (yes/no) "
	read operation_code
	
	while true; do
		if [ "${operation_code}" = yes ]; then
			# remove old
			remove_docker
			echo -e "\n\n Docker remove is successful ! \n\n"
			# install new
			install_docker_from_repo
			echo -e "\n\n docker installation is successful ! \n\n"
		
			break
		fi
		if [ "${operation_code}" = no ]; then
			break
		fi
		echo -n "Do you want to reinstaled it? (yes/no) "
		read operation_code
	done
else
	# just install 
	install_docker_from_repo
	echo -e "\n\n docker installation is successful ! \n\n"
fi 



# ENDING
echo -e "--------------------------------------------------------"
echo -e "View docker status: sudo systemctl status docker"
echo -e "Start docker: sudo systemctl start docker"
echo -e "Verify that Docker Engine: sudo docker run hello-world"
echo -e "--------------------------------------------------------"