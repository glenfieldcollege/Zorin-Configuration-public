#!/bin/bash

#    Zorin Configuration Script For A School Environment With AD, Student Shared Drives, PaperCut, etc.
#    Copyright (C) 2023  Glenfield College - David Charles Keenleyside.
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#  Fresh Zorin configuration script.  This will configure all of the zorin settings and applications needed for an AD Joined
#  system to function with student accounts, and automatically mount their drives on login.

#  Extra services are also included, it is expected that you will comment out non-applicable lines for your org.
#  However, for services which are listed which you currently do not use, ask yourself "why?"  There are many systems which are very helpful.

# IMPORTANT: Make sure you have added the local admin user and also named the machine correctly before running this script.
# IMPORTANT: Make sure Zorin has been added to Samba Active Directory 4 during the installation process, this script will not do it for you.
# IMPORTANT: Make sure all zorin updates have been applied, and user logins tested as still working, before running this script.

# This script must be run from the folder containing all required files, or it will fail.
# Failure may result in a non-functional system.

#  Make sure you run a test account first against AD, to confirm working.
#  Make sure all updates are installed first.
#  Make sure you have rebooted.

# Wazuh setup and install lines - Wazuh is highly recommended.
sudo apt -y install curl # Extra for Ubuntu.
sudo curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && sudo chmod 644 /usr/share/keyrings/wazuh.gpg
sudo echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee -a /etc/apt/sources.list.d/wazuh.list
sudo apt-get update

sudo WAZUH_MANAGER="XXX.XXX.XXX.XXX" apt-get install wazuh-agent

sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

#  Fix the hosts entries, to avoid DNS lookup errors on Zerotier joined systems like DOM1
echo XXX.XXX.XXX.XXX   dom1 dom1.some.school.nz | sudo tee --append /etc/hosts
echo XXX.XXX.XXX.XXX   dom2 dom2.some.school.nz | sudo tee --append /etc/hosts
echo XXX.XXX.XXX.XXX   dom3 dom3.some.school.nz | sudo tee --append /etc/hosts
echo XXX.XXX.XXX.XXX   student student.some.school.nz | sudo tee --append /etc/hosts

# Copy in our working Kerberos configuration - Make sure you have configured this for your environment.

sudo cp krb5.conf /etc/krb5.conf
sudo chmod 0644 /etc/krb5.conf
sudo chown root:root /etc/krb5.conf

#  Now we prepare the system for the KRB5 join.
sudo apt -y install libpam-mount
sudo apt -y install libpam-krb5
sudo apt -y install krb5-user
sudo apt -y install cifs-utils
sudo apt install hxtools
sudo apt install keyutils
sudo apt -y install mlocate
sudo apt install python3-smbc
sudo apt install libpam-ccreds
sudo apt -y install smbclient

sudo pam-auth-update --enable libpam-mount
sudo pam-auth-update --enable libpam-krb5
#sudo pam-auth-update --enable mkhomedir # As on Ubuntu 24.04.1

# We need to make sure we have identified our auth provider
echo "auth_provider = ad" | sudo tee --append /etc/sssd/sssd.conf
# Ensure we have permissive GPO access control - otherwise logins will fail randomly.
echo "ad_gpo_access_control = permissive" | sudo tee --append /etc/sssd/sssd.conf

#  Copy in our working pam mount security file with adjustments.
# sudo mkdir /etc/skel/.config # For Ubuntu
sudo cp pam_mount.conf.xml.security /etc/security/pam_mount.conf.xml
sudo chmod 0644 /etc/security/pam_mount.conf.xml
sudo chown root:root /etc/security/pam_mount.conf.xml

# Prepare Skel.

#sudo mkdir /etc/skel/PDrive
#sudo mkdir /etc/skel/FDrive
#sudo mkdir /etc/skel/TDrive

#  Copy in our working pam mount configuration into skel.
sudo cp pam_mount.conf.xml.home.skel /etc/skel/.config/pam_mount.conf.xml
sudo chmod 0644 /etc/skel/.config/pam_mount.conf.xml
sudo chown root:root /etc/skel/.config/pam_mount.conf.xml

# Checked as good until this point.

#  Configure Pam Common session to mount the user directories after new user creation: Otherwise, this fails on first log in.
echo "session optional  pam_mount.so" | sudo tee --append /etc/pam.d/common-session

# Turn on the Zorin Startup Tune.  Not present in Ubuntu.
sudo sed -i 's/X-GNOME-Autostart-enabled=false/X-GNOME-Autostart-enabled=true/' /etc/skel/.config/autostart/canberra-gtk-play.desktop

# Make sure the school CA is added to the certificate store
sudo cp freeipa.ipa.some.school.nz.pem /etc/ssl/certs/
sudo update-ca-certificates

# Prepare user related login changes for CA Installation on login.
sudo cp Install_CA_Certificates.sh /etc/skel/.config/Install_CA_Certificates.sh
sudo chmod 0644 /etc/skel/.config/Install_CA_Certificates.sh
sudo chown root:root /etc/skel/.config/Install_CA_Certificates.sh

# Install Google Chrome - Make sure this package is present in the script directory.
sudo dpkg -i google-chrome-stable_current_amd64.deb

# We want Chrome to autostart on user log in.
# sudo mkdir /etc/skel/.config/autostart # make this directory in Ubuntu
sudo cp google-chrome-autostart.desktop /etc/skel/.config/autostart/google-chrome-autostart.desktop
sudo chmod 0644 /etc/skel/.config/autostart/google-chrome-autostart.desktop
sudo chown root:root /etc/skel/.config/autostart/google-chrome-autostart.desktop

# Make Google Chrome the default browser system-wide.
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/google-chrome 500
sudo update-alternatives --set x-www-browser /usr/bin/google-chrome
echo "xdg-settings set default-web-browser google-chrome.desktop" | sudo tee --append /etc/skel/.bashrc

# Install Google Earth - Make sure this package is present in the script directory.
sudo dpkg -i google-earth-pro-stable_current_amd64.deb

## Papercut and printer systems.

# Put the PC Client in position for PaperCut - Make sure this directory is present in the script directory.
sudo apt -y install default-jdk
sudo mkdir /opt/PaperCut-Client
sudo cp -R linux /opt/PaperCut-Client/
sudo chmod +x /opt/PaperCut-Client/linux/pc-client-linux.sh

# Copy the Autostart configuration into skel - Make sure this config is present in the script directory.
sudo cp papercut-client-autostart.desktop /etc/skel/.config/autostart/papercut-client-autostart.desktop
sudo chmod 0644 /etc/skel/.config/autostart/papercut-client-autostart.desktop
sudo chown root:root /etc/skel/.config/autostart/papercut-client-autostart.desktop

# The client needs to run when a user logs in.
sudo cp Open_PaperCut_Client.sh /etc/skel/
sudo chmod +x /etc/skel/Open_PaperCut_Client.sh

#  Below a printer driver is bring added, best to put yours here.
#  Install the printer driver - Make sure this package is present in the script directory.
sudo dpkg -i fflinuxprint_1.1.3-4_amd64.deb

# Configure the printer
# Do this manually for the moment.
# Example printers using lpadmin
#sudo lpadmin -p FollowMe -E -v smb://printing.some.school.nz/FollowMe -L "//printing.some.school.nz" -P /usr/share/ppd/fujifilm/fflinuxprint.ppd -o auth-info-required=username,password
#sudo lpadmin -p R43-Printer -E -v socket://XXX.XXX.XXX.XXX:9100 -L "Room 43 Printer" -m postscript-hp:0/ppd/hplip/HP/hp-laserjet_e60055-e60075-ps.ppd

#Adjust Followme printer settings to force authentication - Do manually for now.
#sudo systemctl stop cups
#sudo sed -i 's/AuthInfoRequired none/AuthInfoRequired username,password/' /etc/cups/printers.conf
#sudo systemctl start cups

## On a school network, where there may be rather a lot of printers, you don't want everything under the sun adding itself.
# Stop cups automatically adding network printers.
sudo systemctl stop cups
#sudo nano /etc/cups/cups-browsed.conf
# change BrowseRemoteprotocols to an empty string, best comment out original and make new line.
sudo sed -i 's/BrowseRemoteProtocols dnssd cups/BrowseRemoteProtocols none/' /etc/cups/cups-browsed.conf
sudo sed -i 's/# BrowseLocalProtocols none/BrowseLocalProtocols none/' /etc/cups/cups-browsed.conf
sudo sed -i 's/# BrowseProtocols none/BrowseProtocols none/' /etc/cups/cups-browsed.conf
sudo systemctl start cups

# It can be easier to list printers here, so you can work with this list as you are setting the machine up.
# The Library printer is an M605n, it lives at XXX.XXX.XXX.XXX
# The papercut printer is at smb://printing.some.school.nz/FollowMe

# install Quality of life packages.
sudo apt -y install mlocate
sudo apt -y install neofetch
sudo apt -y install glances
sudo apt -y install krita
sudo apt -y install inkscape
sudo apt -y install thunderbird
sudo apt -y install filezilla
sudo apt -y install blender
sudo apt -y install ubuntu-restricted-extras
sudo apt -y install libnss3-tools
sudo apt -y install veyon # This will install the most modern version of Veyon.
sudo apt -y install gnome-tweaks # Enable the right-click button on touchpads, by running tweaks, then Keyboard & mouse -> Mouse Click Emulation -> Area [tick this]
sudo apt -y install kdeedu # The KDE education applications metapackage.
sudo apt -y install colobot # Educational programming game.
sudo apt -y install games-education # Debians educational games collection.
sudo apt -y install labplot # Excellent Data Analysis and Visualization Tool
sudo apt -y install kdenlive # For Video editing.
sudo apt -y install freecad # For CAD Design.
#sudo apt -y install 

# Firefox ESR requires special handling, should you require it.
#sudo add-apt-repository -y ppa:mozillateam/ppa
#sudo apt -y install firefox-esr

#  Install SSH based tools and enable the SSH server, for remote management purposes - make sure you use keys for logging in.
sudo apt -y install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

# Adjust apt unattended updates actually to provide updates.
# Remember to edit: /etc/apt/apt.conf.d/50unattended-upgrades

# Note: OLD: Ensure that pam_mount in /etc/pam.d/session-auth has the try_first_password setting.

## LAPTOP SPECIFIC

# Hint: Allow a user to change network settings in the network manager; for wifi at home.  Manually edit crontab.
# sudo crontab -e
# @reboot sed -i '/System policy prevents modification of network settings for all users/,/allow_active/s/allow_active>auth_admin_keep/allow_active>yes/' /usr/share/polkit-1/actions/org.freedesktop.NetworkManager.policy

## END LAPTOP SPECIFIC

## TEACHER COMPUTER SPECIFIC

# Hint: On a teacher's machine, you probably want to install Veyon Master if you use Veyon on your network.
# sudo apt -y install veyon-master

## END TEACHER COMPUTER SPECIFIC

# Hint: You might want to add routes during boot time dynamically.  eth0 is an example; your network interface name might be different.  Manual crontab edit.
# sudo crontab -e
# @reboot sudo ip route add XXX.XXX.XXX.XXX/XX via XXX.XXX.XXX.XXX dev eth0

## Updates specific

# Update everything.
#sudo apt ref
#sudo apt dist-upgrade --download-only
#sudo apt dist-upgrade

# Uattended updates work well, but sometimes you have something special, like packages in extra repositories, and you just want it to work
# So, here are some hints for crontab (sudo crontab -e) for two packages with extra niceties.  You could always remove --download-only, and have everything update, but that's fairly dangerous.
# Always install Chrome every 3 hours, thus capturing updated versions.  Also, preemptively download all updates, but don't install them.
#0 */3 * * * apt update && apt -y install google-chrome-stable && apt -y dist-upgrade --download-only # Chrome version.
#(sudo crontab -l; echo "0 */3 * * * apt update && apt -y install google-chrome-stable && apt -y dist-upgrade --download-only # Chrome version.") | sudo crontab -
#0 16 * * * apt update && apt -y dist-upgrade # Update everything at 4pm.
#(sudo crontab -l; echo "0 16 * * * apt update && apt -y dist-upgrade # Update everything at 4pm.") | sudo crontab -
#0 */3 * * * apt update && apt -y install firefox-esr && apt -y dist-upgrade --download-only # Firefox ESR version.
#(sudo crontab -l; echo "0 */3 * * * apt update && apt -y install firefox-esr && apt -y dist-upgrade --download-only # Firefox ESR version.") | sudo crontab -

## End updates specific

# Students have a habit of messing around with the Grub boot menu, and there is a bug in OS prober, which ignores the 0 seconds timeout in grub.cfg.
# Only set this if you are using Zorin OS only.
#sudo sed -i 's/set timeout=10/set timeout=0/' /etc/grub.d/30_os-prober
#sudo update-grub

## Veyon-specific configuration changes for Zorin 17 - uncomment as needed.
#sudo sed -i 's/# WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf  # Veyon does not support wayland, so switch all systems to X11
#sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf  # Veyon does not support wayland, so switch all systems to X11
#Note: The wayland # WaylandEnable spacing changes sometimes.
# The above change only takes effect on reboot.

# Zorin specific configuration changes.

# Make sure everything is tested, and the system is rebooted and tested, before installing the login manager to make changes.

# Zorin 16.3 Specific:
xhost SI:localuser:gdm
sudo -u gdm gsettings set org.gnome.login-screen disable-user-list true
sudo -u gdm gsettings set org.gnome.login-screen banner-message-text 'Login Using your EMail Account'
sudo -u gdm gsettings set org.gnome.login-screen banner-message-enable true
sudo -u gdm gsettings set org.gnome.desktop.lockdown disable-lock-screen true
sudo -u gdm gsettings set org.gnome.desktop.lockdown disable-user-switching true
sudo -u gdm gsettings set org.gnome.desktop.screensaver lock-enabled false
sudo -u gdm gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false

# Ubuntu and Zorin 17 specific:
# sudo mkdir /etc/dconf/profile/
# sudo echo "user-db:user" | sudo tee --append /etc/dconf/profile/gdm
# sudo echo "system-db:gdm" | sudo tee --append /etc/dconf/profile/gdm
# sudo echo "file-db:/usr/share/gdm/greeter-dconf-defaults" | sudo tee --append /etc/dconf/profile/gdm
# sudo mkdir /etc/dconf/db/gdm.d
# sudo echo "[org/gnome/login-screen]" | sudo tee --append /etc/dconf/db/gdm.d/00-login-screen
# sudo echo "# Do not show the user list" | sudo tee --append /etc/dconf/db/gdm.d/00-login-screen
# sudo echo "disable-user-list=true" | sudo tee --append /etc/dconf/db/gdm.d/00-login-screen
# sudo echo "banner-message-text='Login Using Your EMail Account'" | sudo tee --append /etc/dconf/db/gdm.d/00-login-screen
# sudo echo "banner-message-enable=true" | sudo tee --append /etc/dconf/db/gdm.d/00-login-screen
# sudo echo "[org/gnome/desktop/lockdown]" | sudo tee --append /etc/dconf/db/gdm.d/00-login-screen
# sudo echo "disable-lock-screen=true" | sudo tee --append /etc/dconf/db/gdm.d/00-login-screen
# sudo echo "disable-user-switching=true" | sudo tee --append /etc/dconf/db/gdm.d/00-login-screen
# sudo echo "[org/gnome/desktop/screensaver]" | sudo tee --append /etc/dconf/db/gdm.d/00-login-screen
# sudo echo "lock-enabled=false" | sudo tee --append /etc/dconf/db/gdm.d/00-login-screen
# sudo echo "ubuntu-lock-on-suspend=false" | sudo tee --append /etc/dconf/db/gdm.d/00-login-screen
# sudo dconf update

#ALT - Best method for reconfiguring the login screen:
sudo apt install dconf-editor
#xhost SI:localuser:gdm && sudo -u gdm dconf-editor

#Notes:
# No Backports.
