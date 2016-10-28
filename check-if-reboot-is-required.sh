#!/bin/bash

# Based on http://serverfault.com/a/311733/76878
latest=$(rpm -q --last kernel | perl -pe 's/^kernel-(\S+).*/$1/' | head -1)
current=$(uname -r)

echo "Current Kernel: $current"
echo "Latest Kernel:  $latest"
echo

if [ "$latest" = "$current" ]; then
    echo "==> Kernel is up to date"
else
    echo "==> REBOOT REQUIRED"
fi

# Based on http://serverfault.com/a/700286/76878
old_files="$(lsof | grep "(path inode=.*)")"

if [ "$old_files" != "" ]; then
    echo
    echo "These files are in use but no longer exist:"
    echo
    echo "$old_files"
    echo
    echo "==> This may indicate that some services need restarting or a reboot is required"
fi
