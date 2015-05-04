## SteamOS-Tools
Tools and scripts for SteamOS.

## Warning

Please take time to read the [disclaimer](https://github.com/ProfessorKaos64/SteamOS-Tools/blob/master/disclaimer.md).

## Usage

To clone this repository to your local computer, you will need the `git` software package. After this is installed, clone SteamOS-Tools with:
```
git clone https://github.com/ProfessorKaos64/SteamOS-Tools
cd SteamOS-Tools/
```

To update your local copy of files:
```
cd SteamOS-Tools/
git fetch
git merge
```

There is also a testing branch for this repository, but I advise against using it.

Please refer to the readme files in the docs/ folder in this reppository. Normal script execution, sans arguments, goes a little bit like:

```
./script-name.sh
```

## Contents
* cfgs/ - various configuration files, including package lists for Debian software installations.
* docs/ - readme files for each script.
* extra/ - various extra scripts
* scriptmodules/ - plugable bash modules / routines for any of the below scripts.
* README.md - This file.
* add-debian-repos.sh - adds debian repositories for installing Debian Wheezy software.
* build-deb-from-ppa.sh - attempts to build a Debian package from a PPA repository.
* build-deb-from-src.sh - attempts to build a Debian package from a git source tree **[in progress]**
* build-test-chroot.sh - build a Debian or SteamOS jail for testing **[in progress]**
* buld-test-docker.sh - build a Debian or SteamOS package for testing.
* desktop-software.sh - script to install custom and bulk Debian desktop software packages. Please see the readme file in docs/ for the full listing of options.
* steamos-stats.sh - displays useful stats while gaming over SSH from another device.
* pair-ps3-bluetooth.sh - pairs your PS3 blueooth controllers to a supported receiver.

## Wiki
- In time I hope to maintain a colletion of useful articles or links to Steamcommunity Guides that still work, currate them and other such things*.

\* TODO (hey I have other cool stuff, ya know, to do).

## Branches
There are three main branches at the moment

`master`  
Default branch - "stable" work that gets PRs, fixes, priority over all other branches.  
`testing`  
Branch where new scripts are made, larger alterations to existing ones implemented, and more.  
`testing-jessie`  
Now that Jessie is stable, evaluation of current repository and packages is underway. **Not** recommended for use.  

## Pull requests / suggestions
Please submit any issues / suggestions to the issues tracker on the right hand side of this page
or any corrections (with justification) as a Pull Request.

## Troubleshooting
Most scripts in the main folder of the repository write stdout and stderr to `log.txt` in the current directory after completion. Please check this file before submitting any issues or pull requests.
