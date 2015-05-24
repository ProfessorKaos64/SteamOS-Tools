### Disclaimer
Please take time to read the following!

#### General overview
These scripts are written for, and developed on official Valve SteamOS images.

Usage of these scripts is at your own risk! If you are at all concerned about the safety of your SteamOS installation, please have a recent or base root partition backup ready! This is typically captured when SteamOS is first installed. If you wish to update it, and feel ok doing so, please do so now. This can be found in the grub boot menu when you first start your PC. If the boot process skips past this, you will need to change the `GRUB_HIDDEN_TIMEOUT_QUIET` to `true` and the `GRUB_TIMEOUT` settings to 3 or 4 seconds. Plese reference the example snippet below. You will then need to run `sudo update-grub` at a terminal window to update the grub boot file.

```
GRUB_DEFAULT=0
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=false
GRUB_TIMEOUT=3
```

If any of this is foreign, or greek to you, it may be best to not proceed. However, a proper root backup should be fine if you do harm to your system. Please be advised that the root partition recovery will not touch the `/home` user partition. Any files contained within `/home` will be preserved. Besides the root partition, please take care to backup any files you are concerned about.

####Notes regarding apt-pinning / apt-preferences 
Apt-pinning is implemented in the `add-debian-repos.sh` script to give Steam and SteamOS release types highest priority. Beneath this, Debian and Debian-Backports are given a much lower priority. For details on current pin levels, please reference [these](https://github.com/ProfessorKaos64/SteamOS-Tools/blob/master/add-debian-repos.sh#L111) lines of code. If the line number is off, the section is titled "# Create and add required text to preferences file". 

Apt-pin preferences are subject to change. Ideally, the testing branch will be tested properly before hand, and package policy checked with `apt-cache policy` as well. Please submit any suggestions or corrections anyone feels should be made as a pull request.

#### Installing and Uninstalling software
Please pay careful attention while installing software lists, packages, or using any scripts that require software installation. I do my best to ensure no software list or singular package is going to remove or overwrite a Valve SteamOS/Steam package, but please be advised. If a software routine, or software install requires to remove* software, please read the output throughly before proceeding. 

Removing software packages can be tricky, so while there is a "uninstall" option to several scripts, please excercise caution, or remove packages one by one to ensure they will not remove critical SteamOS packages. A listing of default SteamOS packages can be found on [Distrowatch](http://distrowatch.com/table.php?distribution=steamos).

####Conclusion

I will not be responsible for damage done to your SteamOS installation. Please heed these warnings.
