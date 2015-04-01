#!/bin/bash

# -----------------------------------------------------------------------
# Author: 	Michael DeGuzis
# Git:		https://github.com/ProfessorKaos64/scripts
# Scipt Name:	steamos-stats.sh
# Script Ver:	0.6.3
# Description:	Monitors various stats easily over an SSH connetion to
#		gauge performance and temperature loads on steamos.
# Usage:	./steamos-stats.sh -gpu [CHIPSET] -appid [APPID]
# Warning:	You MUST have the Debian repos added properly for 
#		Installation of the pre-requisite packages.
# TODO:		Add AMD GPU support
# ------------------------------------------------------------------------

# Set initial VAR values
APPID_ENABLE="False"
APPID="0"
kernelver=$(uname -r)
# set default for now
active_gpu="nvidia"
supported_gpu="yes"

echo $client_ver
sleep 10

# From user input (until auto detection is figured out), set
# the gpu on the first argument

# valid chipset values: nvidia, intel, fglrx
if [[ "$1" == "-driver" ]]; then
    if [[ "$2" == "nvidia" ]]; then
    	active_gpu="nvidia"
    	supported_gpu="yes"
    elif [[ "$2" == "fglrx" ]]; then
    	active_gpu="fglrx"
	supported_gpu="no"
    elif [[ "$2" == "intel" ]]; then
    	active_gpu="intel"
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
	# VaporOS bindings
	#####################################################"
	# FPS + more binds from VaporOS 2
	# For bindings, see: /etc/actkbd-steamos-controller.conf
	if [[ ! -d "/usr/share/doc/vaporos-binds-xbox360" ]]; then
		echo "VaporOS Xbox 360 bindings not found"
		echo "Attempting to install this now."
		sleep 1s
		cd ~/Downloads
		wget https://github.com/sharkwouter/steamos-installer/blob/master/pool/main/v/vaporos-binds-xbox360/vaporos-binds-xbox360_1.0_all.deb
		sudo dpkg -i vaporos-binds-xbox360_1.0_all.deb
		cd
		if [ $? == '0' ]; then
			echo "Successfully installed 'vaporos-binds-xbox360'"
			sleep 3s
		else
			echo "Could not install 'vaporos-binds-xbox360'. Exiting..."
			sleep 3s
			exit 1
		fi
	else
		echo "Found package 'vaporos-binds-xbox360'."
		sleep 0.5s
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
		if [[ -d "/etc/apt/preferences.bak" ]]; then
			# restore preferences file
			sudo mv "/etc/apt/preferences.bak" "/etc/apt/preferences"
		fi

		# Update
		sudo apt-get update
		cd

		if [ $? == '0' ]; then
			echo "Successfully installed 'voglperf'"
			sleep 3s
		else
			echo "Could not install 'voglperf'. Exiting..."
			sleep 3s
			exit 1
		fi
	else
		echo "Found package 'voglperf'."
		sleep 0.5s
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
		sleep 1s
		echo "Attempting to install these now (Must have Debian Repos added)."
		sleep 1s
		# Update system first
		sudo apt-get update

		# fetch needed pkgs
		sudo apt-get -t wheezy install lm-sensors sysstat git -y
		sudo apt-get install nvidia-smi openssh-server -y
		# detect sensors automatically
		yes | sudo sensors-detect

		if [ $? == '0' ]; then
			echo "Successfully installed pre-requisite packages."
			sleep 3s
		else
			echo "Could not install pre-requisite packages. Exiting..."
			sleep 3s
			exit 1
		fi
	fi

	# output quick checks for intalled packages
	if [[ -n $(type -P sensors) ]]; then
		echo "Sensors Package [Ok]"
		sleep 0.5s
	fi

	if [[ -n $(type -P free) ]]; then
		echo "Found package 'free' [Ok]."
		sleep 0.5s
	fi

	if [[ -n $(type -P git) ]]; then
		echo "Found package 'ssh' [Ok.]"
		sleep 0.5s
	fi

	# notify user if GPU is supported by utility
	echo "Supported GPU: $supported_gpu"
	sleep 1s

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


####################################################################
# Start Loop
####################################################################
while :
do

	########################################
	# Set VARS
	########################################
	CEL=$(echo $'\xc2\xb0'C)

	CPU=$(less /proc/cpuinfo | grep -m 1 "model name" | cut -c 14-70)
	CPU_TEMPS=$(sensors | grep -E '(Core|Physical)'| iconv -f ISO-8859-1 -t UTF-8)

	#also see: xxd, iconv
	CPU_LOAD=$(iostat | cut -f 2 | grep -A 1 "avg-cpu")
	MEM_LOAD=$(free -m | grep -E '(total|Mem|Swap)' |  cut -c 1-7,13-18,23-29,34-40,43-51,53-62,65-73)

	# Determine which GPU chipset we are dealing with
	# Currently, Nvidia is only supported
	if [[ "$active_gpu" == "nvidia" ]]; then
		# Nvidia detected
		GPU=$(nvidia-smi -a | grep -E 'Name' | cut -c 39-100)
		GPU_DRIVER=$(nvidia-smi -a | grep -E 'Driver Version' | cut -c 39-100)
		GPU_TEMP=$(nvidia-smi -a | grep -E 'Current Temp' | cut -c 39-40 | sed "s|$|$CEL|g")
		GPU_FAN=$(nvidia-smi -a | grep -E 'Fan Speed' | cut -c 39-45 | sed "s| %|%|g")

	elif [[ "$active_gpu" == "fglrx" ]]; then
		GPU="          [temporarily disabled]"
		GPU_DRIVER="[temporarily disabled]"
		GPU_TEMP="          [temporarily disabled]"
		GPU_FAN="     [temporarily disabled]"

	elif [[ "$active_gpu" == "intel" ]]; then
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
	echo "Monitoring CPU and GPU statistics  |  Kernel: $kernelver "
	echo "###########################################################"
	echo "Press [CTRL+C] to stop.."
	echo ""
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

	# let stat's idel for a bit
	sleep 1s

done
pkill voglperfrun64
