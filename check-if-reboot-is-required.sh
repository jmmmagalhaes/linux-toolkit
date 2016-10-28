#!/bin/bash

# Based on http://serverfault.com/a/311733/76878
latest=$(rpm -q --last kernel | perl -pe 's/^kernel-(\S+).*/$1/' | head -1)
current=$(uname -r)

echo "Current Kernel: $current"
echo "Latest Kernel:  $latest"
echo

if [ "$latest" = "$current" ]; then
    echo "No reboot is required"
else
    echo "REBOOT REQUIRED"
fi
