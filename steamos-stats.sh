#!/bin/bash

# -----------------------------------------------------------------------
# Author: 	Michael DeGuzis
# Git:		https://github.com/ProfessorKaos64/scripts
# Scipt Name:	steamos-stats.sh
# Script Ver:	0.7.2
# Description:	Monitors various stats easily over an SSH connetion to
#		gauge performance and temperature loads on steamos.
# Usage:	./steamos-stats.sh -gpu [gfx driver] -appid [APPID]
# Warning:	You MUST have the Debian repos added properly for 
#		Installation of the pre-requisite packages.
# TODO:		Add AMD GPU support
# ------------------------------------------------------------------------

# remove old custom files
rm -f "log.txt"
rm -f "log_tmp.txt"

funct_set_main_vars()
{
	# Set initial VAR values
	APPID_ENABLE="False"
	APPID="0"
	kernel_ver=$(uname -r)
	# set default for now 
	# Valve's installer will use proprietary drivers, if available
	active_driver="nvidia"
	supported_gpu="yes"
}

funct_pre_req_checks()
{
	# From user input (until auto detection is figured out), set
	# the gpu driver on the first argument. 
	# "Unsupported" may just mean the driver has not been tested yet
	
	# valid driver values: nvidia, intel, fglrx, nouveau, radeon
	if [[ "$1" == "-driver" ]]; then
		if [[ "$2" == "nvidia" ]]; then
		    	active_driver="nvidia"
		    	supported_gpu="yes"
		elif [[ "$2" == "nouveau" ]]; then
		    	active_driver="nouveau"
			supported_gpu="no"	
		elif [[ "$2" == "fglrx" ]]; then
		    	active_driver="fglrx"
			supported_gpu="no"
		elif [[ "$2" == "radeon" ]]; then
		    	active_driver="radeon"
			supported_gpu="no"
		elif [[ "$2" == "intel" ]]; then
			active_driver="intel"
			supported_gpu="no"
		fi
	fi
	
	if [[ "$3" == "-appid" ]]; then
		echo "appid detected"
		APPID=$(echo $4)
	fi
	
	# GPU testing ONLY!
	#clear
	#echo "Enabled options:"
	#echo "APP ID used: $APPID_ENABLE"
	#echo "APP ID: $APPID"
	#echo "Kernel Ver: $kernelver"
	#echo "Active GPU $active_gpu"
	#sleep 5s
	
	clear
	####################################################################
	# Check for packages
	####################################################################
	
	echo "#####################################################"
	echo "Package pre-req checks"
	echo "#####################################################"
	echo ""
	
		#####################################################"
		# SteamCMD
		#####################################################"
		# See: https://developer.valvesoftware.com/wiki/SteamCMD
		# steamcmd is not installed to any particular directory, but we
		# will have to assume the user started in the /home/desktop DIR
	
		# steamcmd dependencies
		PKG_OK=$(dpkg-query -W --showformat='${Status}\n' lib32gcc1 | grep "install ok installed")
		
		if [ "" == "$PKG_OK" ]; then
			echo -e "No lib32gcc1 found. Setting up lib32gcc1.\n"
			sleep 1s
			sudo apt-get install lib32gcc1
		else
			echo "Checking for lib32gcc1: [Ok]"
			sleep 0.2s
		fi
	
		# check for SteamCMD's existance in /home/desktop
		if [[ ! -f "/home/desktop/steamcmd/steamcmd.sh" ]]; then
			echo -e "\nsteamcmd not found\n"
			echo -e "Attempting to install this now.\n"
			sleep 1s
			# if directory exists, remove it so we have a clean slate
			if [[ ! -d "/home/desktop/steamcmd" ]]; then
				rm -rf "/home/desktop/steamcmd"
				mkdir ~/steamcmd
			fi
		
			# Download and unpack steamcmd directory
			cd ~/steamcmd
			wget "http://media.steampowered.com/installer/steamcmd_linux.tar.gz"
			tar -xvzf steamcmd_linux.tar.gz
	
			if [ $? == '0' ]; then
				echo "Successfully installed 'steamcmd'"
				sleep 2s
			else
				echo "Could not install 'steamcmd'. Exiting..."
				sleep 2s
				exit 1
			fi
		else
			echo "Found package 'steamcmd' [Ok]"
			sleep 0.2s
		fi
	
		#####################################################"
		# VaporOS bindings (controller shortcuts)
		#####################################################"
		# FPS + more binds from VaporOS 2
		# For bindings, see: /etc/actkbd-steamos-controller.conf
		PKG_OK=$(dpkg-query -W --showformat='${Status}\n' vaporos-binds-xbox360 | grep "install ok installed")
		if [ "" == "$PKG_OK" ]; then
			echo -e "vaporos-binds-xbox360 not found. Setting up vaporos-binds-xbox360 now...\n"
			sleep 1s
			cd ~/Downloads
			wget https://github.com/sharkwouter/steamos-installer/blob/master/pool/main/v/vaporos-binds-xbox360/vaporos-binds-xbox360_1.0_all.deb
			sudo dpkg -i vaporos-binds-xbox360_1.0_all.deb
			cd
			if [ $? == '0' ]; then
				echo "Successfully installed 'vaporos-binds-xbox360'"
				sleep 2s
			else
				echo "Could not install 'vaporos-binds-xbox360'. Exiting..."
				sleep 2s
				exit 1
			fi
		else
			echo "Checking for 'vaporos-binds-xbox360 [OK]'."
			sleep 0.2s
		fi
	
		#####################################################"
		# Voglperf
		#####################################################"
		# Since Voglperf compiles into a bin/ folder, not /usr/bin, we have to
		# assume the git repo was cloned into /home/desktop for now.
		
		if [[ ! -f "/home/desktop/voglperf/bin/voglperfrun64" ]]; then
			echo "Voglperf not found"
			echo "Attempting to install this now..."
			sleep 1s
			# Fetch binaries
			sudo apt-get install steamos-dev 
			# we need to remove apt pinning preferences temporarily only due to the fact
			# that mesa-common-dev has dep issues with apt pinning. This is being looked at
			if [[ -d "/etc/apt/preferences" ]]; then
				# backup preferences file
				sudo mv "/etc/apt/preferences" "/etc/apt/preferences.bak"
			fi 
	 		sudo apt-get update 
	 		sudo apt-get install git ca-certificates cmake g++ gcc-multilib g++-multilib 
	 		sudo apt-get install mesa-common-dev libedit-dev libtinfo-dev libtinfo-dev:i386 
			cd ~
			git clone https://github.com/ValveSoftware/voglperf
			cd voglperf/
			make
	
			# Restore apt preferences if the backup file exists
			if [[ -f "/etc/apt/preferences.bak" ]]; then
				# restore preferences file
				sudo mv "/etc/apt/preferences.bak" "/etc/apt/preferences"
			fi
	
			# Update
			sudo apt-get update
			cd
	
			if [ $? == '0' ]; then
				echo "Successfully installed 'voglperf'"
				sleep 2s
			else
				echo "Could not install 'voglperf'. Exiting..."
				sleep 2s
				exit 1
			fi
		else
			echo "Found package 'voglperf' [Ok]"
			sleep 0.2s
		fi
	
		#####################################################"
		# Other core utilties from official repos 
		#####################################################"
	
		if [[ -z $(type -P sensors) \
		       || -z $(type -P nvidia-smi) \
		       || -z $(type -P sar) \
		       || -z $(type -P git) \
		       || -z $(type -P free) ]]; then
	
			echo "1 or more core packages not found"
			echo -e "Attempting to install these now (Must have Debian Repos added)\n"
			sleep 2s
			# Update system first
			sudo apt-get update
	
			# fetch needed pkgs
			sudo apt-get -t wheezy install lm-sensors sysstat git -y
			sudo apt-get install nvidia-smi openssh-server -y
			# detect sensors automatically
			yes | sudo sensors-detect
	
			if [ $? == '0' ]; then
				echo "Successfully installed pre-requisite packages."
				sleep 2s
			else
				echo "Could not install pre-requisite packages. Exiting..."
				sleep 2s
				exit 1
			fi
		fi
	
		# output quick checks for intalled packages explicitly needed by
		# this script, and are added by a group package like 'sysstat'
		
		if [[ -n $(type -P sensors) ]]; then
			# Group package: sysstat
			echo "Found package 'lm-sensors' [Ok]"
			sleep 0.2s
		fi
	
		if [[ -n $(type -P free) ]]; then
			# Group package: sysstat
			echo "Found package 'free' [Ok]"
			sleep 0.2s
		fi
	
		if [[ -n $(type -P git) ]]; then
			# Group package: sysstat
			echo "Found package 'ssh' [Ok]"
			sleep 0.2s
		fi
	
		# notify user if GPU is supported by utility
		echo "Supported GPU: $supported_gpu"
		sleep 1s
	
		# TESTING ONLY - pause for pkg check testing
		# echo -e "\nPausing for dramatic effect ^_^ "
		# sleep 10s
	
	####################################################################
	# voglperf
	####################################################################
	# Currently assumes hard location path of /home/desktop/voglperf
	# Full AppID game list: http://steamdb.info/linux/
	# Currently, still easier to use Shark's VaporOS package, which adds
	# easy gamepad toggles for an FPS overlay
	
	# Accept game ID argument. If found, turn APPID=True
	if [[ "$APPID_ENABLE" == "true" ]]; then
	   echo ""
	   echo "Arugment detected, attempting to start game ID $APPID"
	   sleep 2s
	   # Volgperf integration is disabled for now
	   # echo -ne 'showfps on\n' |  echo -ne 'game start $APPID \n' | sudo -u steam /home/desktop/voglperf/bin/voglperfrun64
	fi
}

funct_main_loop()
{
	####################################################################
	# Start Loop
	####################################################################
	
	# Loop until a key is pressed [IN TESTING]
	# Credit to http://stackoverflow.com/users/111461/sam-hocevar
	# See: http://stackoverflow.com/a/5297780
	if [ -t 0 ]; then 
		stty -echo -icanon -icrnl time 0 min 0; 
	fi
		
	count=0
	keypress=''

	while [ "x$keypress" = "x" ]; do
		
		let count+=1
		# testing only
	  	# echo -ne $count'\r'
		keypress="`cat -v`"
	
		########################################
		# Set VARS
		########################################
		CEL=$(echo $'\xc2\xb0'C)
	
		CPU=$(less /proc/cpuinfo | grep -m 1 "model name" | cut -c 14-70)
		CPU_TEMPS=$(sensors | grep -E '(Core|Physical)'| iconv -f ISO-8859-1 -t UTF-8)
	
		#also see: xxd, iconv
		CPU_LOAD=$(iostat | cut -f 2 | grep -A 1 "avg-cpu")
		MEM_LOAD=$(free -m | grep -E '(total|Mem|Swap)' |  cut -c 1-7,13-18,23-29,34-40,43-51,53-62,65-73)
		
		# Steam-specific
		# There is a bug in the current steamcmd version that outputs a 
		# Danish "o" in "version"
		steam_ver=$(/home/desktop/steamcmd/steamcmd.sh "+versi$(echo -e '\xc3\xb8')n" +quit | grep "package" | cut -c 25-35)
		steam_api=$(/home/desktop/steamcmd/steamcmd.sh "+versi$(echo -e '\xc3\xb8')n" +quit | grep -E "^Steam API\:" | cut -c 12-15)
	
		# Determine which GPU chipset we are dealing with
		# Currently, Nvidia is only supported
		# Other values: intel, fglrx, nouveau, radeon
		if [[ "$active_driver" == "nvidia" ]]; then
			# Nvidia detected
			GPU=$(nvidia-smi -a | grep -E 'Name' | cut -c 39-100)
			GPU_DRIVER=$(nvidia-smi -a | grep -E 'Driver Version' | cut -c 39-100)
			GPU_TEMP=$(nvidia-smi -a | grep -E 'Current Temp' | cut -c 39-40 | sed "s|$|$CEL|g")
			GPU_FAN=$(nvidia-smi -a | grep -E 'Fan Speed' | cut -c 39-45 | sed "s| %|%|g")
			
		elif [[ "$active_driver" == "nouveau" ]]; then
			GPU="          [temporarily disabled]"
			GPU_DRIVER="[temporarily disabled]"
			GPU_TEMP="          [temporarily disabled]"
			GPU_FAN="     [temporarily disabled]"
	
		elif [[ "$active_driver" == "fglrx" ]]; then
			GPU="          [temporarily disabled]"
			GPU_DRIVER="[temporarily disabled]"
			GPU_TEMP="          [temporarily disabled]"
			GPU_FAN="     [temporarily disabled]"
	
		elif [[ "$active_driver" == "intel" ]]; then
			GPU="          [temporarily disabled]"
			GPU_DRIVER="[temporarily disabled]"
			GPU_TEMP="          [temporarily disabled]"
			GPU_FAN="     [temporarily disabled]"
			
		elif [[ "$active_driver" == "radeon" ]]; then
			GPU="          [temporarily disabled]"
			GPU_DRIVER="[temporarily disabled]"
			GPU_TEMP="          [temporarily disabled]"
			GPU_FAN="     [temporarily disabled]"
			
		elif [[ "$active_driver" == "intel" ]]; then
			GPU="          [temporarily disabled]"
			GPU_DRIVER="[temporarily disabled]"
			GPU_TEMP="          [temporarily disabled]"
			GPU_FAN="     [temporarily disabled]"
	
		else
			#nothing to see here for now
			echo "" > /dev/null
		fi
	
		clear
		echo "###########################################################"
		echo "Monitoring system statistics... |  Press any key to quit  #"
		echo "###########################################################"
		echo "Kernel version: $kernel_ver"
		echo "Steam Client version: $steam_ver"
		echo "Steam API verion: $steam_api"
		########################################
		# GPU Stats
		########################################
		echo "-----------------------------------------------------------"
		echo "GPU Stats"
		echo "-----------------------------------------------------------"
		echo "GPU name: $GPU"
		echo "GPU driver Version: $GPU_DRIVER"
		echo "GPU temp: $GPU_TEMP"
		echo "GPU fan speed: $GPU_FAN"
	
		########################################
		# FPS Stats (vogelperf)
		########################################
	
		#echo $APPID
		if [[ "$APPID_ENABLE" == "False" ]] ; then
	  		# Do not show text
	  		echo "" > /dev/null
		else
			# Placeholder for now
	  		echo "Game FPS: 00.00"
		fi
	
		########################################
		# CPU Stats
		########################################
		# With Cores
		#echo ""
		echo "-----------------------------------------------------------"
		echo "CPU Stats"
		echo "-----------------------------------------------------------"
		echo "CPU Name: $CPU"
		echo ""
		echo "CPU Temp:"
		echo "$CPU_TEMPS"
		echo ""
		echo "CPU Utilization:"
		echo "$CPU_LOAD"
	
		########################################
		# MEMORY Stats
		########################################
		#echo ""
		echo "-----------------------------------------------------------"
		echo "Memory Stats"
		echo "-----------------------------------------------------------"
		echo "$MEM_LOAD"
	
		# let stat's idle for a bit
		sleep 1s
	
	done
	
	if [ -t 0 ]; then 
		stty sane; 
	fi
	
	# exit on keypress notification
	echo "You pressed '$keypress' to end the script"
	exit 0
}

#####################################################
# handle prerequisite software
#####################################################

main ()
{
	funct_set_main_vars
	funct_pre_req_checks
	funct_main_loop
}

#####################################################
# MAIN
#####################################################

main | tee log_temp.txt

#####################################################
# cleanup
#####################################################

# convert log file to Unix compatible ASCII
strings log_temp.txt > log.txt

# strings does catch all characters that I could 
# work with, final cleanup
sed -i 's|\[J||g' log.txt

# remove file not needed anymore
rm -f "log_temp.txt"

# kill any voglperf server
pkill voglperfrun64
