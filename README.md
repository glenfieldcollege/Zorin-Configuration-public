# Zorin-Configuration-public
A public version of the Glenfield College Zorin Configuration scripts.

# Very Simple
Complexity is not the aim; it is already difficult enough for most people to get this working.

# Features - By Section - Includes Examples
The setup script is built to allow the following:
Student Login - Students can log in using their account against an Active Directory.
Student Drives - Student and student shared drives will be automatically mapped for that student; this is the bit 90% of people want but cannot solve.
Wazuh Agent setup - For our convenience, I recommend this to others.  It's easy to comment out.
Startup Tune turned on - For an easy sound test, if a student hears nothing, then something is wrong.
Install a CA certificate - We use an internal Certificate Authority, and you may too.  It's easy to comment out.
Install Google Chrome - As long as the Google Chrome installer is present, it'll install it.
Autostart Chrome - When a student logs in, Chrome will automatically start, saving time for students.
Make Google Chrome the Default - Google Chrome will be the default browser, saving time.
Install Google Earth - To save time, install Google Earth for Students as long as the installer is present.
Install PaperCut Client - It will be installed as long as you have the PaperCut client in the directory.
Autostart the PaperCut Client - The PaperCut client will automatically start for students.
Install Printer Drivers - As long as you list them and have their files present, it is an example.
Tidy CUPS - The CUPS printer system will stop broadcasting printers from the client machine and stop adding them from the network - sensible in a school environment.
Install Quality of Life Applications - Including Veyon.  This is mainly an example list, but useful tools are present.
Enable SSH - SSH will be installed and enabled for remote system maintenance.
GDM Settings - Various GDM settings will be adjusted for student ease of use and to lock down some features.  gconf-editor is also installed for convenience.

# Expectations
This is a simple 1-shot script.  The idea is to adjust the files for your environment, saving you much time.
There are very few examples, if any, of automatic mapping of a student's drives on login, where this is a random student.
Indeed, I didn't find any examples... this script is for those of you looking for a solution.

# Not Perfect
This is not a perfect script; there will be areas you don't want to use, but in that case, comment them out.
There will probably be mistakes, as the script is broad in terms of features and has not been cut down to the bare essentials.
This script is used in a public school environment.  It works for us and will hopefully work for you.
