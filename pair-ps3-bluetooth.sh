#!/bin/bash
# See: https://github.com/rdepena/node-dualshock-controller/wiki/Pairing-The-Dual-shock-3-controller-in-Linux-(Ubuntu-Debian)

# -------------------------------------------------------------------------------
# Author: 	Michael DeGuzis
# Git:		https://github.com/ProfessorKaos64/SteamOS-Tools
# Scipt Name:	pair-ps3-bluetooth.sh
# Script Ver:	0.2.7
# Description:	Pairs PS3 Bluetooth controller on SteamOS
# Usage:	./pair-ps3-bluetooth.sh
#
# Warning:	You MUST have the Debian repos added properly for
#		Installation of the pre-requisite packages.
# -------------------------------------------------------------------------------


install_prereqs()
{

	echo -e "\n==> Installing prerequisite software\n"

	# Fetch what has to be installed from Alchemist (conflicting version)
	sudo apt-get install libbluetooth-dev libusb-dev

	# Fetch what has to be installed from Wheezy
	sudo apt-get -t wheezy install bluez-utils bluez-compat bluez-hcidump \
	checkinstall joystick pyqt4-dev-tools
	
	
}

clean_install()
{
	echo -e "\n==> Stopping sixad service\n"
	# stop  sixad init service if present
	if [[ -f "/etc/init.d/sixad" ]]; then
		sudo service sixad stop
	fi
	
}

main()
{
  
  	clear
	echo -e "\n==> Downloading sixad...\n"
	sleep 1s
	# These are Debian rebuilt packages from the ppa:falk-t-j/qtsixa PPA
	wget -P /tmp "http://www.libregeek.org/SteamOS-Extra/utilities/sixad_1.5.1+git20130130-SteamOS_amd64.deb"
	
	# Install
	echo -e "==> Installing sixad...\n"
	sleep 1s
	sudo dpkg -i "/tmp/sixad_1.5.1+git20130130-SteamOS_amd64.deb"
	
	echo -e "\n==> Downloading sixpair...\n"
	sleep 1s
	# These are Debian rebuilt packages from the ppa:falk-t-j/qtsixa PPA
	wget -P /tmp "http://www.pabr.org/sixlinux/sixpair.c"
	
	echo -e "==> Building and installing sixpair...\n"
	gcc -o "/tmp/sixpair" "/tmp/sixpair.c" -lusb
	
	# move sixpair binary to /usr/bin to execuate in any location in $PATH
	sudo mv "/tmp/sixpair" "/usr/bin"
		
	#configure and start sixad daemon.
	echo -e "==> Configuring sixad...\n"
	sleep 2s
	sudo update-rc.d sixad defaults
	sudo /etc/init.d/sixad enable
	sudo /etc/init.d/sixad start
  
  	echo -e "\c==> Configuring controller(s)...\n"
  	
  	echo -e "\n##############################################"
	echo -e "Please select the number of PS3 controllers"
	echo -e "##############################################"
	echo "(1)"
	echo "(2)"
	echo "(3)"
	echo "(4)"
	echo ""

	# the prompt sometimes likes to jump above sleep
	sleep 0.5s
	read -ep "Choice: " cont_num_choice

	case $cont_num_choice in
	
		1)
		# call pairing function to set current bluetooth MAC to Player 1
		n="1"
		ps3_pair_blu
		echo -e "Pairing of Player $n controller complete\n"
		sleep 2s 
		;;
	
		2)
		
		# call pairing function to set current bluetooth MAC to Player 1
		n="1"
		ps3_pair_blu
		echo -e "Pairing of Player $n controller complete\n"
		sleep 2s 
		
		# call pairing function to set current bluetooth MAC to Player 2
		n="2"
		ps3_pair_blu
		echo -e "Pairing of Player $n controller complete\n"
		sleep 2s 
		;;
	
		3)
	
		# call pairing function to set current bluetooth MAC to Player 1
		n="1"
		ps3_pair_blu
		echo -e "Pairing of Player $n controller complete\n"
		sleep 2s 
	
		# call pairing function to set current bluetooth MAC to Player 2
		n="2"
		ps3_pair_blu
		echo -e "Pairing of Player $n controller complete\n"
		sleep 2s
	
		# call pairing function to set current bluetooth MAC to Player 3
		n="3"
		ps3_pair_blu
		echo -e "Pairing of Player $n controller complete\n"
		sleep 2s
		;;
	
		4)
		# call pairing function to set current bluetooth MAC to Player 1
		n="1"
		ps3_pair_blu
		echo -e "Pairing of Player $n controller complete\n"
		sleep 2s
		
		# call pairing function to set current bluetooth MAC to Player 1
		n="2"
		ps3_pair_blu
		echo -e "Pairing of Player $n controller complete\n"
		sleep 2s
		
		# call pairing function to set current bluetooth MAC to Player 1
		n="3"
		ps3_pair_blu
		echo -e "Pairing of Player $n controller complete\n"
		sleep 2s
		
		# call pairing function to set current bluetooth MAC to Player 1
		n="1"
		ps3_pair_blu
		echo -e "Pairing of Player $n controller complete\n"
		sleep 2s
		;;
	
	esac
	
	###########################################################
	# End controller pairing process
	###########################################################
	
	# start the service at boot time
	sixad --boot-yes
	
	# Alternatively:
	# sudo update-rc.d sixad defaults
	
}
	
ps3_pair_blu()
{
	echo -e "\n#########################################"
	echo -e "Please plug in these items now:"
	echo -e "#########################################"
	echo -e "(1) The USB cable"
	echo -e "(2) PS3 controller $n"
	echo -e "(3) Bluetooth dongle\n"
	echo -e "Additional controllers can be added in the settings menu"
	echo -e "\nPress [ENTER] to continue."
	
	read -n 1
        echo -e  "\nContinuing...\n"
	
	clear
	# Grab player 1 controller MAC Address of wired device
	echo -e "\n==> Setting up Playstation 3 Sixaxis (bluetooth) [Player $n]\n"
	sleep 2s
	
	# Pair controller with logging 
	# if hardcoded path is needed, sixpair should be in /usr/bin now
	sudo sixpair
	sleep 2s
	
	# Inform player 1 controller user to disconnect USB cord
	echo -e "\nPlease disconnect the USB cable and press the PS Button now. The appropriate \
	LED for player $n should be lit. If it is not, please hold in the PS button to turn it off, then \
	back on.\n\nThere is no need to reboot to fully enable the controller(s)"
	
	clear
	echo -e "######################################################"
	echo -e "Notice for Steam users:"
	echo -e "######################################################\n"

	echo -e "Using the left stick and pressing the left and right stick navigate to the Settings Screen \
and edit the layout of the controller. By default, the left joystick should work and left-stick click will be\
assigned to OK/Confirm\n"

}

##################################################### 
# Install prereqs 
##################################################### 
clean_install
install_prereqs

##################################################### 
# MAIN 
##################################################### 
main | tee log_temp.txt 

#################################################### 
# cleanup 
##################################################### 

# cleanup deb packages and leftovers
rm -f "/tmp/sixad_1.5.1+git20130130-SteamOS_amd64.deb"
rm -f "/tmp/sixpair.c"

# apt cleanup
sudo apt-get autoremove

# convert log file to Unix compatible ASCII 
strings log_temp.txt > log.txt 

# strings does catch all characters that I could  
# work with, final cleanup 
sed -i 's|\[J||g' log.txt 

# remove file not needed anymore 
rm -f "log_temp.txt" 
