#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

# Get the server name
server=$(hostname -s)

# Loop through all cPanel users (don't use /home/* because it includes other directories too)
for user in /var/cpanel/users/*; do
    user=$(basename $user)
    home=/home/$user
    fwdfile=$home/.forward

    # If the .forward file doesn't exist already, create it
    if [ -d "$home" -a ! -f "$fwdfile" ]; then
        # Display a message only if we create any - it will be sent as an email by cron
        email="support+bounces@alberon.co.uk"
        echo "Creating $fwdfile (to $email)"
        echo "$email" > $fwdfile
        chown $user:$user $fwdfile
        chmod 644 $fwdfile
    fi
done
