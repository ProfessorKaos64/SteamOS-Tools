#!/bin/bash
# -------------------------------------------------------------------------------
# Author:    	  	Michael DeGuzis
# Scipt Name:	  	fetch-steamos.sh
# Script Ver:		1.2.2
# Description:		Fetch latest Alchemist and Brewmaster SteamOS release files
#			to specified directory and run SHA512 checks against them.
#			Installs to a USB drive. 
#			This NOT associated with Valve whatsover.
#
# Usage:      		./fetch-steamos.sh 
#			./fetch-steamos.sh --help
#			./fetch-steamos.sh --checkonly
# -------------------------------------------------------------------------------
arg1="$1"

show_banner()
{


	# show banner
	cat <<-EOF
	@@@@@@@@@@@@@@@@@@@@@@&*.........../&@@@@@@@@@@@@@@@@@@@@@@
	@@@@@@@@@@@@@@@@&*.......................*&@@@@@@@@@@@@@@@@
	@@@@@@@@@@@@@................................*@@@@@@@@@@@@@
	@@@@@@@@@@(.....................................(@@@@@@@@@@
	@@@@@@@@(.....STEAMOS MEGA........................&@@@@@@@@
	@@@@@@/..........DOWNLOADER......... .*/*. .........(@@@@@@
	@@@@@............................@@@@@@@@@@@@&........@@@@@
	@@@&..........................*@@@@@@&**/&@@@@@@.......@@@@
	@@&..........................@@@@@...&@@@(...@@@@*......&@@
	@@........................../@@@&..@@@@@@@@@..@@@@ ......@@
	@...........................@@@@..@@@@@@@@@@@..@@@&.......@
	(..........................*@@@@./@@@@@@@@@@@..@@@&.......&
	..........................@@@@@@..(@@@@@@@@@/.&@@@.........
	.........................@@@@@@@@*..@@@@@@@..&@@@&.........
	@@&....................&@@@@@@@@@@@@.......@@@@@(..........
	@@@@@@@&..............@@@@@@@@@@@@@@@@@@@@@@@@&............
	@@@@@@@@@@@@&....*&@@@@@@@@@@@@@@@@@@@@@@@@/...............
	@@@@@@@@@@@@@@@@@@@&&@@@@@@@@@@@@@@@@(.....................
	@@@@@@@@@@@@@@@@@@@@@@**.@@@@@@@@@&.**********************&
	@*&@@@@@@@@@@@@@@@@@@@@@**&@@@@&**************************@
	@@*****&@@@@@@@@@@@@@@@@@**@@****************************@@
	@@&********(@@@@@@@@@@@@(*(@@***************************&@@
	@@@&/////////@@*(@@@@@@*//@@*//////////////////////////&@@@
	@@@@@////////*@@@&/***/@@@@///////////////////////////@@@@@
	@@@@@@(/////////(@@@@@@&////////////////////////////&@@@@@@
	@@@@@@@@(/////////////////////////////////////////&@@@@@@@@
	@@@@@@@@@@(/////////////////////////////////////&@@@@@@@@@@
	@@@@@@@@@@@@@(((((((((((((((((((((((((((((((((@@@@@@@@@@@@@
	@@@@@@@@@@@@@@@@&(((((((((((((((((((((((((&@@@@@@@@@@@@@@@@	
	EOF
	sleep 5s
	
	
}

help()
{
	
	clear
	cat <<-EOF
	#####################################################
	Help file
	#####################################################
	
	Usage:
	
	./steamos-mega-downloader.sh 		-fetch release, checked for file integrity
	./steamos-mega-downloader..sh --help	-show this help file
	./steamos-mega-downloader. --checkonly	-Check existing release files (if exist)
	
	Please note:
	Stephenson's Rocket and VaporOS are not official Valve releases of SteamOS.
	
	The utility will also offer to image/unzip the release to your USB drive.
	This utility is NOT associated with Valve whatsover.
	
	EOF
	
}

pre_reqs()
{
	# check fo existance of dirs
	if [[ ! -d "$HOME/downloads/$release" ]]; then
		mkdir -p "$HOME/downloads/$release"
	fi
	
	echo -e "\n==> Checking for prerequisite packages\n"
	
	#check for distro name
	distro_check=$(lsb_release -i | cut -c 17-25)
	
	############################################
	# Debian
	############################################
	if [[ "$distro_check" == "Debian" ]]; then
	
		echo -e "Distro detected: Debian"
		
		deps="apt-utils xorriso syslinux rsync wget p7zip-full realpath unzip"
		for dep in ${deps}; do
			pkg_chk=$(dpkg-query -s ${dep})
			if [[ "$pkg_chk" == "" ]]; then
				sudo apt-get install ${dep}
				
				if [[ $? = 100 ]]; then
					echo -e "Cannot install ${dep}. Please install this manually \n"
					exit 1
				fi
				
			else
				echo "package ${dep} [OK]"
			fi
		done
		
	############################################
	# SteamOS
	############################################
	elif [[ "$distro_check" == "SteamOS" ]]; then

		# Debian sources are required to install xorriso for Stephenson's Rocket
		sources_check1=$(sudo find /etc/apt -type f -name "jessie*.list")
		sources_check2=$(sudo find /etc/apt -type f -name "wheezy*.list")
		
		if [[ "$sources_check1" == "" && "$sources_check2" == "" ]]; then
		
			echo -e "\n==WARNING==\nDebian sources are needed for xorriso, add now? (y/n)"
			read -erp "Choice: " sources_choice
		
			if [[ "$sources_choice" == "y" ]]; then
				../add-debian-repos.sh
			elif [[ "$sources_choice" == "n" ]]; then
				echo -e "Sources addition skipped"
			fi
			
		fi
		
		# Note: added isolinux, as syslinux contained within SteamOS does not contain
		# isohdpfx.bin, but isolinux does.
		deps="apt-utils xorriso syslinux rsync wget p7zip-full realpath isolinux unzip"
		for dep in ${deps}; do
			pkg_chk=$(dpkg-query -s ${dep})
			if [[ "$pkg_chk" == "" ]]; then
				sudo apt-get install ${dep}
				
				if [[ $? = 100 ]]; then
					echo -e "Cannot install ${dep}. Please install this manually \n"
					exit 1
				fi
				
			else
				echo "package ${dep} [OK]"
				sleep .3s
			fi
		done
	
	############################################
	# Ubuntu
	############################################
	elif [[ "$distro_check" == "Ubuntu" ]]; then
	
		echo -e "Distro detected: Ubuntu"
		
		deps="apt-utils xorriso syslinux rsync wget p7zip-full realpath unzip"
		for dep in ${deps}; do
			pkg_chk=$(dpkg-query -s ${dep})
			if [[ "$pkg_chk" == "" ]]; then
				sudo apt-get install ${dep}
				
				if [[ $? = 100 ]]; then
					echo -e "Cannot install ${dep}. Please install this manually \n"
					exit 1
				fi
				
			else
				echo "package ${dep} [OK]"
			fi
		done
	
	############################################
	# Arch Linux
	############################################
	elif [[ "$distro_check" == "Arch" ]]; then
		
		echo -e "Distro detected: Arch Linux"
		echo -e "Only official Valve releases are supported at this time!\n"
		sleep 2s
		
		# Check dependencies (stephensons and vaporos-mod)
		deps="libisoburn syslinux coreutils rsync p7zip wget unzip git"
		for dep in ${deps}; do
			pkg_chk=$(pacman -Q ${dep})
			if [[ "$pkg_chk" == "" ]]; then
				sudo pacman -S  ${dep}
				
				if [[ $? = 100 ]]; then
					echo -e "Cannot install ${dep}. Please install this manually \n"
					exit 1
				fi
				
			else
				echo "package ${dep} [OK]"
				sleep .3s
			fi
		done
			
		# apt (need for stephenson's rocket / vaporos-mod)
		pkg_chk=$(pacman -Q apt)
		if [[ "$pkg_chk" == "" ]]; then
		
			mkdir -p /tmp/apt
			wget -P /tmp "https://aur.archlinux.org/cgit/aur.git/snapshot/apt.tar.gz"
			tar -C /tmp/ -xzvf /tmp/apt.tar.gz
			cd /tmp/apt
			makepkg -sri
			rm -rf /tmp/apt/
			
		fi
	
	############################################
	# All Others
	############################################	
	else
	
		echo -e "Warning!: Distro not supported"
		sleep 3s
		exit 1
		
	fi
	
}

show_summary()
{
	
	cat <<-EOF
	
	------------------------------------------------------------
	Summary
	------------------------------------------------------------
	
	Your USB drive is now ready. Please reboot your computer with the
	USB drive connected. Either set your computer to boot from a 
	USB device first, or select it from the boot menu. Please ensure
	that before booting the USB drive, you ensure you have the proper
	EFI settings (if applicatble) for your motherboard.
	
	If you chose to burn an applicable ISO image to a CD or DVD,
	please reboot your computer with the disc inserted.
	
	Please see github.com/ValveSoftware/SteamOS/wiki for more.
	
	EOF
}

burn_disc()
{

	# find out drive name
	drive_name=$(cat "/proc/sys/dev/cdrom/info" | grep "drive name" | cut -f 3 )
	optical_drive=$(echo /dev/${drive_name})
	
	# burn ISO image
	xorriso -as cdrecord -v dev=${optical_drive} blank=as_needed ${file}

	# eject disc for labeling or examination
	eject ${optical_drive}
	
	# show user end summary
	show_summary
	
}

create_usb_iso()
{

	echo -e "\n==> Showing current usb drives\n"
	lsblk
	
	echo -e "\n==> Enter drive path (e.g. /dev/sdX):"
	sleep 0.5s
	read -erp "Choice: " drive_choice
	
	echo -e "\n==> Formatting drive\n"
	
	# mount, format, and mount again :P
	sudo umount ${drive_choice}*
	$format_drive ${drive_choice} 
	
	echo -e "\n==> Installing release to usb drive..."
	echo -e "    This will take some time, please wait.\n"
	
	# image drive
	sudo dd bs=1M if=${file} of=${drive_choice}
	
	# unount drive 
	echo -e "\nUmounting USB drive. Please do not remove until done"
	sudo umount ${drive_choice} 
	echo -e "Done"
	sleep 2s
	
	# show user end summary
	show_summary
	
}

create_usb_zip()
{
	
	echo -e "\n==> Showing current usb drives\n"
	lsblk
	
	echo -e "\n==> Enter drive path (usually /dev/sdX):"
	sleep 0.5s
	read -erp "Choice: " drive_choice
	
	echo -e "\n==> Formatting drive\n"
	
	# mount, format, and mount again :P
	sudo umount ${$drive_choice}*
	$format_drive ${$drive_choice}
	
	# create tmp dir and moutn drive
	if [[ -d "/tmp/steamos-usb" ]]; then
		rm -rf "/tmp/steamos-usb/*"
	else
		mkdir -p "/tmp/steamos-usb"
	fi
	
	# mount drive to tmp location
	sudo mount "$drive_choice" "/tmp/steamos-usb"
	
	echo -e "\n==> Installing release to usb drive\n"
	
	# unzip archive to drive
	sudo unzip "$file" -d "/tmp/steamos-usb"
	
	# unount drive 
	echo -e "\nUmounting USB drive. Please do not reove until done"
	sudo umount "$drive_choice" 
	
	# show user end summary
	show_summary
	
}

install_image()
{
	# check $file extension
	# ask user if they wish to use a DVD/CD or USB drive for ISO images later below
	check_iso=$(echo $file | grep -i iso)
	check_zip=$(echo $file | grep -i zip)
	
	# set mkdosfs location
	if [[ "$distro_check" == "SteamOS" || "$distro_check" == "Debian" ]]; then
	
		format_drive="sudo /sbin/mkdosfs -F 32 -I"
	
	else
		
		format_drive="sudo mkdosfs -F 32 -I"
	
	fi
	
	echo -e "\nWould you like to make a USB drive or CD/DVD (ISO type only)? (y/n)"
	read -erp "Choice: " choice
	echo ""
	
	if [[ "$choice"  == "y" ]]; then
	
		# detect zip file
		if [[ "$check_zip" != "" ]]; then
			
			create_usb_zip
			
		# detect ISO image
		elif [[ "$check_iso" != "" ]]; then
		
			echo -e "\nDo you wish to use a USB Drive (u), or a Disc (d)? "
			echo -e "An average 1.4 GB DVD is needed for Disc imaging\n"
			read -erp "Choice: " ud_choice
			echo ""
			
			if [[ "$ud_choice" == "u" ]]; then
		
				create_usb_iso
				
			elif [[ "$ud_choice" == "d" ]]; then
			
				burn_disc
				
			fi
			
			# provide if statement soon to choose optical method as well
			
		else
		
			echo -e "\nRelease not supported for this operation. Aborting..."
			clear
			exit 1
			
		fi
		
	elif [[ "$choice"  == "n" ]]; then
	
		echo -e "Skipping USB installation"
		
	fi
	
}

check_download_integrity()
{
  
	echo -e "\n==> Checking integrity of installer\n"
	sleep 2s

	# If the checksum file exists and the user did not choose to overwrite
	# the release, the clobber option flag will essentially skip downloading
	# and keep the local version of the checksum

	# download md5sum
	if [[ "$md5file" != "none" ]];then
	
		if [[ "$distro" == "stephensons-rocket" || "$distro" == "vaporos-mod" ]]; then
		
			# This is handled during build
			echo "" > /dev/null
			
		elif [[ "$distro" == "vaporos" ]]; then
		
			wget --no-clobber "$base_url/iso/$md5file"
		
		else
			wget --no-clobber "$base_url/$release/$md5file"
			
		fi
		
	else
		
		echo -e "\nMD5 Check:\nNo file to check"
	
	fi
	
	# download shasum
	if [[ "$shafile" != "none" ]];then
	
		if [[ "$distro" == "stephensons-rocket" ]]; then
		
			# This is handled during build
			echo "" > /dev/null
			
		elif [[ "$distro" == "vaporos" ]]; then
		
			# no shafile currently for release
			echo "" > /dev/null
		
		else
		
			# wget as normal
			wget --no-clobber "$base_url/$release/$shafile"
			
		fi
	
	else
		
		echo -e "SHA check:\nNo file to check"
	
	fi
	
	# for some reason, only the brewmaster integrity check files have /var/www/download in them
	if [[ "$release" == "alchemist" ]]; then
		
		# do nothing
		echo "" > /dev/null
		
	elif [[ "$release" == "brewmaster" ]]; then
	
		orig_prefix="/var/www/download/brewmaster/"
		#new_prefix="$HOME/downloads/$release";
		
		if [[ "$distro" == "valve-official" ]]; then
		
			sed -i "s|$orig_prefix||g" "$HOME/downloads/$release/$shafile"
			sed -i "s|$orig_prefix||g" "$HOME/downloads/$release/$md5file"
			
		fi
	
	fi
	
	# Check md5sum of installer
	if [[ "$md5file" != "none" ]];then
	
		if [[ "$distro" == "valve-official" ]]; then
		
			# strip extra line(s) from Valve checksum file
			#sed -i "/$file/!d" $md5file
			:
			
		fi
	
		echo -e "\nMD5 Check:"
		# we only want to check for our $file only below
		md5check=$(md5sum -c "$HOME/downloads/$release/$md5file" | grep "$file: OK")
		
		if [[ "$md5check" == "$file: OK" ]]; then
			# output check test
			echo -e "$md5check"
			
		else
			# let user know check failed and to retry with overwrite
			#clear
			echo -e "\n==ERROR==\nmd5sum check failed.\nPlease rerun this script and choose to overwrite"
			exit 1
		fi
		
	fi
	
	# Check sha512sum of installer
	if [[ "$shafile" != "none" ]];then
	
		if [[ "$distro" == "valve-official" ]]; then
		
			# strip extra line(s) from Valve checksum file
			#sed -i "/$file/!d" $shafile
			:
			
		fi
		
		echo -e "\nSHA512 Check:"
		# we only want to check for our $file only below
		shacheck=$(sha512sum -c "$HOME/downloads/$release/$shafile" | grep "$file: OK")
		
		if [[ "$shacheck" == "$file: OK" ]]; then
			# output check test
			echo "$shacheck"
			
		else 
			# let user know check failed and to retry with overwrite
			#clear
			echo -e "\n==ERROR==\nsha512sum check failed.\nPlease rerun this script and choose to overwrite"
			exit 1
		fi
		
	fi
  
}

eval_git_repo()
{

	# set fallback if true
	# Ths likely only is used in cases where simple bugs can be fixed in a
	# local fork and used until upstream is fixed.
	if [[ "$fallback" == "true" ]]; then
	
		# set gitrul to fallback url
		giturl="$giturl_fallback"
		echo -e "\n==INFO==\nUsing fallback git url."
	
	fi
	
	if [[ -d "$HOME/downloads/$release/$gitdir" ]]; then
	
		echo -e "\n==INFO==\nGit DIR $gitdir exists, trying remote pull"
		sleep 2s
	
		# change to git folder
		cd "$HOME/downloads/$release/$gitdir"
		
		# remove previous ISOs and checksum (if exists)
		rm -f "$file"
		rm -f "$md5sum"
		rm -f "SteamOSDVD.iso"
		
		# eval git status
		output=$(git pull)
		
		# evaluate git pull. Remove, create, and clone if it fails
		if [[ "$output" != "Already up-to-date." ]]; then
	
			echo -e "\n==Info==\nGit directory pull failed. Removing and cloning\n"
			sleep 2s
			rm -rf "$HOME/downloads/$release/$distro"

			# clone
			git clone $giturl
		
			# Enter git repo
			cd "$gitdir"
	
		else
		
			# echo output
			echo -e "$output"
		fi
	
	else
		# git dir does not exist, clone
		git clone $giturl
		
		# Enter git repo
		cd "$gitdir"
	
	fi
	
}

download_valve_steamos()
{
	# Downloads singular file (mainly ISO images or Valve's installers)
	# Also used for legacy VaporOS (ISO image)
	
	# remove previous files if desired
	if [[ "$HOME/downloads/$release/$file" ]]; then
		
		echo -e "\n$file exists, overwrite? (y/n)"
		# get user choice
		read -erp "Choice: " rdl_choice
		
		if [[ "$rdl_choice" == "y" ]]; then
		
			# remove and download
			rm -f "$HOME/downloads/$release/$file"
			rm -f "$HOME/downloads/$release/$md5file"
			rm -f "$HOME/downloads/$release/$shafile"
			echo ""
			wget --no-clobber "$base_url/$release/$file"
			
		elif [[ "$rdl_choice" == "n" ]]; then
		
			# Do not overwrite files
			# If checksum does not exist, it will be downloaded in the integrity check function
			# If the checksum file exists, the --clobber flag will keep the existing checksum
			# due to the filename matching the remote.
			# If integrity check fails, users should overwrite on retry
			echo "" > /dev/null
	
		fi
	else
	
		# file does not exist, download
		wget --no-clobber "$base_url/$release/$file"
		
	fi
	
}

download_vaporos_legacy()
{
	# Downloads singular file (mainly ISO images or Valve's installers)
	# Also used for legacy VaporOS (ISO image)
	
	# remove previous files if desired
	if [[ "$HOME/downloads/$release/$file" ]]; then
		
		echo -e "\n$file exists, overwrite? (y/n)"
		# get user choice
		read -erp "Choice: " rdl_choice
		
		if [[ "$rdl_choice" == "y" ]]; then
		
			# remove and download
			rm -f "$HOME/downloads/$release/$file"
			rm -f "$HOME/downloads/$release/$md5file"
			rm -f "$HOME/downloads/$release/$shafile"
			echo ""
			wget --no-clobber "$base_url/iso/$file"
			
		elif [[ "$rdl_choice" == "n" ]]; then
		
			# Do not overwrite files
			# If checksum does not exist, it will be downloaded in the integrity check function
			# If the checksum file exists, the --clobber flag will keep the existing checksum
			# due to the filename matching the remote.
			# If integrity check fails, users should overwrite on retry
			echo "" > /dev/null
	
		fi
	else
	
		# file does not exist, download
		wget --no-clobber "$base_url/iso/$file"
		
	fi
	
}

download_stephensons()
{
	# Downloads and builds iso/checksum for Stephenson's Rocket or
	# VaporOS-Mod
	
	# set fallback if there is an issue upstream (will use professorkaos64 fork below)
	# Fallback set: 20150901
	# See: https://github.com/steamos-community/stephensons-rocket/pull/111
	fallback="true"
	
	# eval repo status for Stephenson's Rocket
	eval_git_repo
	
	# remove apt-specific packages, handled in pre_req function
	if [[ "$distro_check" == "Arch" ]]; then
		sed -i 's|apt-utils xorriso syslinux rsync wget p7zip-full realpath||g' gen.sh
	fi
	
	# Generate image andchecksum files
	if [[ "$distro" == "vaporos-mod" ]]; then
	
		echo -e "\n==INFO==\nVaporOS-mod detected"
		sleep 2s
		
		# set new giturl and eval
		giturl="$giturl_alt"
		gitdir="$gitdir_alt"
		# remove fallback for eval
		fallback="false"
		
		# eval repo status
		eval_git_repo
		
		cd ..
		echo ""
		./gen.sh -n "VaporOS" vaporos-mod
		
	else
	
		# generate "stock" iso image
		echo ""
		./gen.sh
		
	fi
	
	# move iso up a dir for easy md5/sha checks and for storage
	echo -e "\n==> Transferring files to release folder\n"
	sleep 2s
	
	mv -v "$file" "$HOME/downloads/$release/"
	mv -v "$md5file" "$HOME/downloads/$release/"
	
	# move to release folder for checksum validation
	cd "$HOME/downloads/$release"

}

download_release_main()
{
	
	# enter base directory for release
	cd "$HOME/downloads/$release"
	
	# download requested file (Valve official)
	if [[ "$distro" == "valve-official" ]]; then
	
		download_valve_steamos
	
	# download requested file (VaporOS legacy)	
	elif [[ "$distro" == "vaporos" ]]; then
	
		download_vaporos_legacy

	# download requested file (VaporOS legacy)	
	elif [[ "$distro" == "vaporos-mod" ]]; then
	
		download_stephensons
		
	# download requested file (Stephenson's Rocket variant)
	elif [[ "$distro" == "stephensons-rocket" ]]; then 
		
		download_stephensons
		
	fi
}


main()
{
	clear
	
	# banner test
	# show_banner
	# clear
	
	# set distro for title header
	distribution=$(lsb_release -i | cut -c 17-25)
	codename=$(lsb_release -c | cut -c 11-25)
	
	cat <<-EOF
	------------------------------------------------------------
	SteamOS Mega Downloader |     Distro: $distribution ($codename)
	------------------------------------------------------------
	For more information, see the wiki at: 
	github.com/ValveSoftware/SteamOS/wiki
	
	EOF
	
	# set base DIR
	base_dir="$HOME/downloads"

	# prompt user if they would like to load a controller config
	
	cat <<-EOF
	Please choose a release to download.
	Releases are checked for integrity
	
	(1) Alchemist (standard zip, UEFI only)
	(2) Alchemist (legacy ISO, BIOS systems)
	(3) Brewmaster (standard zip, UEFI only)
	(4) Brewmaster (legacy ISO, BIOS systems)
	(5) Stephensons Rocket (Alchemist repsin)
	(6) Stephensons Rocket (Brewmaster repsin)
	(7) VaporOS (Alchemist, Legacy ISO)
	(8) VaporOS (Alchemist, Stephenson's Rocket Mod)
	(9) VaporOS (Brewmaster, Stephenson's Rocket Mod)

	EOF
  	
  	# the prompt sometimes likes to jump above sleep
	sleep 0.5s
	
	read -erp "Choice: " rel_choice
	
	case "$rel_choice" in
	
		1)
		distro="valve-official"
		base_url="repo.steampowered.com/download"
		release="alchemist"
		file="SteamOSInstaller.zip"
		git="no"
		md5file="MD5SUMS"
		shafile="SHA512SUMS"
		;;
		
		2)
		distro="valve-official"
		base_url="repo.steampowered.com/download"
		release="alchemist"
		file="SteamOSDVD.iso"
		git="no"
		md5file="MD5SUMS"
		shafile="SHA512SUMS"
		;;
		
		3)
		distro="valve-official"
		base_url="repo.steampowered.com/download"
		release="brewmaster"
		file="SteamOSInstaller.zip"
		git="no"
		md5file="MD5SUMS"
		shafile="SHA512SUMS"
		;;
		
		4)
		distro="valve-official"
		base_url="repo.steampowered.com/download"
		release="brewmaster"
		file="SteamOSDVD.iso"
		git="no"
		md5file="MD5SUMS"
		shafile="SHA512SUMS"
		;;
		
		5)
		distro="stephensons-rocket"
		release="alchemist"
		file="rocket.iso"
		git="yes"
		gitdir="stephensons-rocket"
		giturl="--depth=1 https://github.com/steamos-community/stephensons-rocket.git --branch $release"
		giturl_fallback="--depth=1 https://github.com/professorkaos64/stephensons-rocket.git --branch $release"
		md5file="rocket.iso.md5"
		shafile="none"
		# set github default action
		pull="no"
		;;
		
		6)
		distro="stephensons-rocket"
		release="brewmaster"
		file="rocket.iso"
		git="yes"
		gitdir="stephensons-rocket"
		giturl="--depth=1 https://github.com/steamos-community/stephensons-rocket.git --branch $release"
		giturl_fallback="--depth=1 https://github.com/professorkaos64/stephensons-rocket.git --branch $release"
		md5file="rocket.iso.md5"
		shafile="none"
		# set github default action
		pull="no"
		;;
		
		7)
		distro="vaporos"
		base_url="http://trashcan-gaming.nl"
		release="alchemist"
		file="vaporos2.1.iso"
		git="no"
		md5file="vaporos2.1.iso.md5"
		shafile="none"
		;;
		
		8)
		distro="vaporos-mod"
		base_url="https://github.com/sharkwouter/vaporos-mod.git"
		release="alchemist"
		file="vaporos.iso"
		git="yes"
		gitdir="stephensons-rocket"
		gitdir_alt="stephensons-rocket/vaporos-mod"
		giturl="--depth=1 https://github.com/steamos-community/stephensons-rocket.git --branch $release"
		giturl_fallback="--depth=1 https://github.com/professorkaos64/stephensons-rocket.git --branch $release"
		giturl_alt="https://github.com/sharkwouter/vaporos-mod.git"
		md5file="vaporos.iso.md5"
		shafile="none"
		# set github default action
		pull="no"
		;;
		
		9)
		distro="vaporos-mod"
		release="brewmaster"
		file="vaporos.iso"
		git="yes"
		gitdir="stephensons-rocket"
		gitdir_alt="stephensons-rocket/vaporos-mod"
		giturl="--depth=1 https://github.com/steamos-community/stephensons-rocket.git --branch $release"
		giturl_fallback="--depth=1 https://github.com/professorkaos64/stephensons-rocket.git --branch $release"
		giturl_alt="https://github.com/sharkwouter/vaporos-mod.git"
		md5file="vaporos.iso.md5"
		shafile="none"
		# set github default action
		pull="no"
		;;
		
		*)
		echo "Invalid Input, exiting"
		exit 1
		;;
	
	esac
	
	# assess if download is needed
	if [[ "$arg1" == "--checkonly" ]]; then
 
 		# just check integrity of files
 		check_download_integrity
 		
 	else
 		# Check for and download release
 		pre_reqs
 		download_release_main
		check_download_integrity
		install_image
		
 	fi
 	
} 

#######################################
# Start script
#######################################

# MAIN
main
