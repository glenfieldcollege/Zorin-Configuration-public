# Zorin-Configuration-public

A public version of the Glenfield College Zorin Configuration scripts.

# Very Simple

Complexity is not the aim; it is already difficult enough for most people to get this working.

# Features - By Section - Includes Examples

The setup script is built to allow the following:

Student Login - Students can log in using their account against an Active Directory.

Student Drives - Student and student shared drives will be automatically mapped for that student; this is the bit 90% of people want but cannot solve.

Let's repeat that: Students using Linux systems can have their SMB shares mounted automatically and dynamically, depending on the user, and in a lab environment.

Wazuh Agent setup - For our convenience, I recommend this to others.  It's easy to comment out.

Startup Tune turned on - For an easy sound test, if a student hears nothing, then something is wrong.

Install a CA certificate - We use an internal Certificate Authority, and you may too.  It's easy to comment out.

Install Google Chrome - As long as the Google Chrome installer is present, it'll install it.

Autostart Chrome - When a student logs in, Chrome will automatically start, saving time for students.

Make Google Chrome the Default - Google Chrome will be the default browser, saving time.

Install Google Earth - To save time, install Google Earth for Students as long as the installer is present.

Install PaperCut Client - If you have the PaperCut client in the directory, it will be installed.

Autostart the PaperCut Client - The PaperCut client will automatically start for students.

Install Printer Drivers - As long as you list them and have their files present, it is an example.

Tidy CUPS - The CUPS printer system will stop broadcasting printers from the client machine and stop adding them from the network - sensible in a school environment.

Install Quality of Life Applications - Including Veyon.  This is mainly an example list, but useful tools are present.

Enable SSH - SSH will be installed and enabled for remote system maintenance.

Hints - There are hint sections to give an idea of the settings you might want to apply for a given scenario.

GDM Settings - Various GDM settings will be adjusted for student ease of use and to lock down some features.  gconf-editor is also installed for convenience.

Note: Some lines are marked as Ubuntu Specific (22.04 tested), and this script will indeed set up Ubuntu as well; you will need to uncomment lines accordingly.

# Expectations

This is a simple 1-shot script.  The idea is to adjust the files for your environment, saving you much time.

There are very few examples, if any, of automatic mapping of a student's drives on login, where this is a random student.

Indeed, I didn't find any examples... this script is for those of you looking for a solution.

You are expected to join your Zorin instance to your Active directory during the OS installation process and test if this is working.

This script will not join your machine to the Active Directory for you; it is a post-deployment script.

# Not Perfect

This is not a perfect script; there will be areas you don't want to use, but in that case, comment them out.

There will probably be mistakes, as the script is broad in terms of features and has not been cut down to the bare essentials.

This script is used in a public school environment.  It works for us and will hopefully work for you.

This has been tested and used with Zorin 16.3, and should work with other versions.

# Areas to Edit
krb5.conf : You'll want to adjust all lines containing "some.school.nz" to your AD server entries.

Open_Papercut_Client.sh : The Zorin_Deploy.sh script copies the PaperCut client to opt; if you have it somewhere else, you need to adjust /opt/PaperCut-Client/linux/pc-client-linux.sh in this file to the actual location.

pam_mount.conf.xml.home.skel : This contains example entries; all server, mount point and path entries must be changed for your environment.  The UID might need changing if you have student IDs below 5 digits.

user-dirs.defaults : I have example P T and F drives in here; you'll want to adjust those to what you set in pam_mount.conf.xml.home.skel , or something which fits your environment.

Zorin_Deploy-public.sh : All XXX.XXX.XXX.XXX entries need to be adjusted for your real IP addresses.  All lines containing some.school.nz need to be adjusted to reflect your environment.

As long as you have your settings right, and the required packages, it should go line by line, performing the desired actions.  On a demo machine, you can also do this by hand, line by line, to see if the desired outcome is achieved.

# Fixes
After finding a bug and checking on Veyon versions, I found Veyon was now available as a single metapackage; and as a more recent version.

This fixes the student login and out bug, which prevents the Veyon server and worker processes from running and, thus, the Veyon master program from seeing and controlling the student's desktop.

If you used a prior version of the script on a client machine, you can remove the old packages and install the new metapackage on a previously deployed client by performing:

sudo apt remove veyon-service veyon-plugins

Then install the new version with:

sudo apt install veyon
