#!/bin/bash
# -------------------------------------------------------------------------------
# Author:    		Michael DeGuzis
# Git:			https://github.com/ProfessorKaos64/SteamOS-Tools
# Scipt Name:	  	build-kodi-src.sh
# Script Ver:		0.5.9
# Description:		Attempts to build a deb package from kodi-src
#               	https://github.com/xbmc/xbmc/blob/master/docs/README.linux
#               	This is a fork of the build-deb-from-src.sh script. Due to the 
#               	amount of steps to build kodi, it was decided to have it's own 
#               	script. A deb package is built from this script. 
#
# Usage:      		./build-kodi-src.sh --cores [cpu cores]
#			./build-kodi-src.sh --package-deb
# See Also:		https://packages.debian.org/sid/kodi
# -------------------------------------------------------------------------------

time_start=$(date +%s)
time_stamp_start=(`date +"%T"`)

###################
# global vars
###################

# default for packaging attempts
packag_deb="no"
skip_to_build="no"

# set default concurrent jobs if called standalone or
# called with extra_opts during 'dekstop-software install kodi-src --cores $n'

###################
# global vars
###################

# Assess build_opts from desktop-software.sh
# Allow more concurrent threads to be specified
if [[ "$build_opts" == "--cores" ]]; then

	# build_opts used from desktop-sofware.sh, set to extra_opts $n
	cores="$extra_opts"
	
elif [[ "$arg1" == "--cores" ]]; then

	# set cores to $arg2 when called standalone
	cores="$arg2"
	
else

	# default to 2 cores as fallback
	cores="2"
fi
	

# assess extra opts from dekstop-software.sh
if [[ "$extra_opts" == "--package-deb" || "$arg1" == "--package-deb" ]]; then

	# set package to yes if deb generation is requested
	package_deb="yes"
	
elif [[ "$extra_opts" == "--skip-build" || "$arg1" == "--skip-build" ]]; then

	# If Kodi is confirmed by user to be built already, allow build
	# to be skipped and packaging to be attempted directly
	skip_build="yes"
	package_deb="yes"
	
fi

##################################
# Informational
##################################

# Source build notes:
# https://github.com/xbmc/xbmc/blob/master/docs/README.linux

# Current version:
# https://github.com/xbmc/xbmc/blob/master/version.txt

# model control file after:
# https://packages.debian.org/sid/kodi

# Current checkinstall config:
# cfgs/source-builds/kodi-checkinstall.txt

kodi_prereqs()
{
	clear
	
	cat <<-EOF
	-----------------------------------------------------------
	Kodi-src build script
	-----------------------------------------------------------
	
	EOF
	
	# Main build dependencies are installed via desktop-software.sh
	# from the software list cfgs/software-lists/kodi-src.txt
	
	# required for building kodi debs
	if [[ "$package_deb" == "yes" ]]; then
	
		echo -e "\n==> Installing build deps for packaging\n"
		sleep 2s
	
		sudo apt-get install build-essential fakeroot devscripts checkinstall \
		cowbuilder pbuilder debootstrap cvs fpc gdc libflac-dev \
		libsamplerate0-dev libgnutls28-dev
	
		echo -e "\n==> Installing build deps sourced from ppa:team-xbmc/xbmc-ppa-build-depends\n"
		sleep 2s

		# origin: https://launchpad.net/~team-xbmc/+archive/ubuntu/xbmc-ppa-build-depends
		# packages are now in the packages.libregeek.org pool

		sudo apt-get install libcec3 libcec-dev libafpclient-dev libgif-dev \
		libmp3lame-dev libshairplay-dev
	
	fi

}

kodi_package_deb()
{
	
	# Debian link: 	    https://wiki.debian.org/BuildingTutorial
	# Ubuntu link: 	    https://wiki.ubuntu.com/PbuilderHowto
	# XBMC/Kodi readme: https://github.com/xbmc/xbmc/blob/master/tools/Linux/packaging/README.debian
	
	# Maybe use sudo "bash -c 'cat "TEXT" >> "/etc/sudoers'""
	# These next 3 lines will need added to /etc/sudoers, if not added already
	
	# Defaults env_reset,env_keep="DIST ARCH CONCURRENCY_LEVEL"
	# Cmnd_Alias PBUILDER = /usr/sbin/pbuilder, /usr/bin/pdebuild, /usr/bin/debuild-pbuilder
	# Desktop ALL=(ALL) PBUILDER
	
	# copy pbuilder template
	# If called standalone change copy paths
	
	############################################################
	# Assess if we are to build for host/ARCH we have or target
	############################################################
	
	echo -e "Build Kodi for our host/ARCH or for all? [host|target]"
	
	# get user choice
	sleep 0.2s
	read -erp "Choice: " build_choice

	if [[ "$build_choice" == "host" ]]; then
	
		# build of the main debian build script ONLY
		tools/Linux/packaging/mk-debian-package.sh
		
	elif [[ "$build_choice" == "target" ]]; then
		
		# ask for DIST target
		echo -e "\nEnter DIST to build for (see utilities/pbuilder-helper.txt)"
		
		# get user choice
		sleep 0.2s
		read -erp "Choice: " dist_choice
		
		if [[ "$scriptdir" == "" ]]; then
	
			
			# copy files based of pwd
			touch "$HOME/.pbuilderrc"
			sudo touch "/root/.pbuilderrc"
			cp ../pbuilder-helper.txt "$HOME/.pbuilderrc"
			sudo cp ../pbuilder-helper.txt "/root/.pbuilderrc"
			
		else
	
			# add desktop file for SteamOS/BPM
			touch "$HOME/.pbuilderrc"
			sudo touch "/root/.pbuilderrc"
			cp "$scriptdir/utilities/pbuilder-helper.txt" "$HOME/.pbuilderrc"
			sudo cp "$scriptdir/utilities/pbuilder-helper.txt" "/root/.pbuilderrc"
			
		fi
		
		# setup dist base
		if sudo DIST=brewmaster pbuilder create; then
		
			echo -e "\nBrewmaster environment created successfully!"
			
		else 
		
			echo -e "\nBrewmaster environment creation FAILED!"
			exit 1
		fi
	
	
		# Clean xbmc pbuilder dir
		rm -rf "/home/$USER/xbmc-packaging/pbuilder"
		mkdir -p "/home/$USER/xbmc-packaging/pbuilder"
		
		# create directory for dependencies
		mkdir -p "/home/$USER/xbmc-packaging/deps"
		
		RELEASEV=16 \
		DISTS="$dist_choice" \
		ARCHS="amd64" \
		BUILDER="pdebuild" \
		PDEBUILD_OPTS="--debbuildopts \"-j4\"" \
		PBUILDER_BASE="/home/$USER/xbmc-packaging/pbuilder" \
		DPUT_TARGET="local" \
		tools/Linux/packaging/mk-debian-package.sh

	# end building
	fi

}

kodi_clone()
{
	
	echo -e "==> Cloning the Kodi team repository"
	
	# set build dir
	build_dir="$HOME/kodi/"

	# If git folder exists, evaluate it
	# Avoiding a large download again is much desired.
	# If the DIR is already there, the fetch info should be intact

	# Skip to build attempt if requested
	if [[ "$skip_build" == "yes" ]]; then
	
		# fire off deb packaging attempt
		echo -e "\n==> Skipping build. Attempting to package existing files in ${build_dir}\n"
		sleep 2s
		cd "$build_dir"
		kodi_package_deb
		exit 1
		
	fi

	if [[ -d "$build_dir" ]]; then

		echo -e "\n==Info==\nGit folder already exists! Reclone [r] or pull [p]?\n"
		sleep 1s
		read -ep "Choice: " git_choice

		if [[ "$git_choice" == "p" ]]; then
			# attempt to pull the latest source first
			echo -e "\n==> Attempting git pull..."
			sleep 2s

			# attempt git pull, if it doesn't complete reclone
			if ! git pull; then
				
				# command failure
				echo -e "\n==Info==\nGit directory pull failed. Removing and cloning...\n"
				sleep 2s
				rm -rf "$build_dir"
				# create and clone to $HOME/kodi
				cd
				git clone git://github.com/xbmc/xbmc.git kodi
				
			fi

		elif [[ "$git_choice" == "r" ]]; then
			echo -e "\n==> Removing and cloning repository again...\n"
			sleep 2s
			sudo rm -rf "$build_dir"
			# create and clone to $HOME/kodi
			cd
			git clone git://github.com/xbmc/xbmc.git kodi

		else

			echo -e "\n==Info==\nGit directory does not exist. cloning now...\n"
			sleep 2s
			# create and clone to $HOME/kodi
			cd
			git clone git://github.com/xbmc/xbmc.git kodi

		fi

	else

			echo -e "\n==Info==\nGit directory does not exist. cloning now...\n"
			sleep 2s
			# create DIRS
			cd
			# create and clone to current dir
			git clone git://github.com/xbmc/xbmc.git kodi

	fi

}

kodi_build()
{
	#################################################
	# Build Kodi
	#################################################

	echo -e "\n==> Building Kodi in $build_dir\n"

	# enter build dir
	cd "$build_dir"

  	# create the Kodi executable manually perform these steps:
	./bootstrap

	# ./configure <option1> <option2> PREFIX=<system prefix>... 
	# (See --help for available options). For now, use the default PREFIX
        # A full listing of supported options can be viewed by typing './configure --help'.
	# Default install path is:

	./configure

	# make the package
	# By adding -j<number> to the make command, you describe how many
     	# concurrent jobs will be used. So for quad-core the command is:

	# make -j4
	
	# Default core number is 2 if '--core' argument is not specified
	make -j${cores}

	# Install Kodi if package generation is not called
	
	if [[ "$package_deb" == "no" ]]; then
	
		# install source build
		sudo make install
		
	elif [[ "$package_deb" == "yes" ]]; then
	
		echo -e "\n==> Attempting to package Kodi\n"
		sleep 3s
	
		# Attempt to build package, confirm first since buiding takes some time
		# get user choice
		echo -e "Attempt to package Kodi? [y/n]"
		sleep 0.3s
		
		read -erp "Choice: " build_choice
		
		if [[ "$build_choice" == "y" ]]; then
		
			kodi_package_deb
			
		elif [[ "$build_choice" == "n" ]]; then
		
			echo -e "\nEXITING"
			exit 1
			
		fi
		
	fi

	# From v14 with commit 4090a5f a new API for binary addons is available. 
	# Not used for now ...

	# make -C tools/depends/target/binary-addons

	####################################
	# (Optional) build Kodi test suite
	####################################

	#make check

	# compile the test suite without running it

	#make testsuite

	# The test suite program can be run manually as well.
	# The name of the test suite program is 'kodi-test' and will build in the Kodi source tree.
	# To bring up the 'help' notes for the program, type the following:

	#./kodi-test --gtest_help

	#################################################
	# Post install configuration
	#################################################

}

show_summary()
{

	cat <<-EOF
	----------------------------------------------------------------
	Summary
	----------------------------------------------------------------
	Time started: ${time_stamp_start}
	Time started: ${time_stamp_end}
	Total Runtime (minutes): $runtime

	You should now be able to add Kodi as a non-Steam game in Big
	Picture Mode. Please see see the wiki for more information
	
	EOF
	sleep 2s
	
}

kodi_post_cfgs()
{
	
	echo -e "\n==> Adding desktop file and artwork"

	# If called standalone change copy paths
	if [[ "$scriptdir" == "" ]]; then

		
		# copy files based of pwd
		sudo cp ../../cfgs/desktop-files/kodi.desktop "/usr/share/applications"
		sudo cp ../../artwork/banners/Kodi.png "/home/steam/Pictures"
		
	else

		# add desktop file for SteamOS/BPM
		sudo cp "$scriptdir/cfgs/desktop-files/kodi-src.desktop" "/usr/share/applications"
		sudo cp "$scriptdir/artwork/banners/Kodi.png" "/home/steam/Pictures"
		
	fi

	#################################################
	# Cleanup
	#################################################

	# clean up dirs

	# note time ended
	time_end=$(date +%s)
	time_stamp_end=(`date +"%T"`)
	runtime=$(echo "scale=2; ($time_end-$time_start) / 60 " | bc)
	
	# check if Kodi really installed
	if [[ -f "/usr/bin/kodi" ]]; then
	
		echo -e "\nKodi was installed successfully."
		
	else 
	
		echo -e "Kodi install unsucessfull"
	
	fi
	
	
}

####################################################
# Script sequence
####################################################
# Main order of operations
kodi_prereqs
kodi_clone
kodi_build
kodi_post_cfgs
