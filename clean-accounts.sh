#!/bin/bash

#  Over time, accounts build up on a machine, and you would like a way of cleaning them off of it.
#  This particular script will remove accounts based on an ID number prefix, and check if that ID Number is a logged in user.
#  If the user is logged in, it will skip that account, and remove all others not logged in.
#  This script can be extremely dangerous if you don't know what you are doing, so test for your environment carefully.
#  Now, why are we so careful about these logged in users?  Multiple users can be logged in aside from the one at the
#  keyboard.  Given our main script mounts their shared drives, there is a danger of not only deleting the local data, but
#  also the remote data... you probably don't want that to happen.  Therefore, only fully logged-out accounts are eliminated.

# Function to check disk usage
check_disk_usage() {
  df -h / | grep -w '/$' | awk '{ print $5 }' | cut -d '%' -f 1
}

#  In this example, because it will be a consdierable amount of time before we reach the year 3000, the ID number begins with 2.
#  Simply adjust this to fit your requirements, and be aware this script is built for a system using ID Numbers for accounts.
#  You could reduce this down to a simple *, but then there is a danger of capturing admin and other accounts.
remove_dirs() {
  for dir in /home/2*; do
    user_prefix="${dir##*/}"  # Extract directory name without path
    user_prefix="${user_prefix%@*}"  # Extract prefix before @

    # Check if user is logged in
    who | grep -q "^$user_prefix"
    if [ $? -eq 0 ]; then
      echo "User $user_prefix is logged in. Skipping deletion."
    else
      echo "Deleting directory for user $user_prefix"
      rm -rf "$dir"
    fi
  done
}

# Main script logic
disk_usage=$(check_disk_usage)

if [ "$disk_usage" -ge 80 ]; then
  echo "Disk usage is at or above 80%. Removing directories starting with '2'..."
  remove_dirs
else
  echo "Disk usage is below 80%. No action taken."
fi

# Simple but ultra dangerous example which would also delete logged in users and their mapped drive contents.
#remove_dirs() {
#  find /home  -depth -type d -name '2*' | while read dir; do
#    rm -rf "$dir"
#  done
#}
