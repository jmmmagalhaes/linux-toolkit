#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

# Parse options
if [ "${1:-}" = "-v" ]; then
    verbose=true
else
    verbose=false
fi

# Helpers
debug() {
    if $verbose; then
        echo "$1"
    fi
}

# Loop through all the repo composer lock files for active users
debug "Looking for active accounts..."
for account in $(egrep -v ':(/bin/noshell|/bin/false|/sbin/nologin)$' /etc/passwd | cut -d: -f6 | grep ^/home/ | sort); do

    debug "Locating composer.lock files in ${account}..."
    for file in $(locate $account/**/composer.lock | grep -v /vendor/ | grep -v "^$account/.composer/"); do

        # Check against sensiolabs
        debug "Checking $file..."
        response=$(curl -H 'Accept: text/plain' -s https://security.symfony.com/check_lock -F lock=@$file)

        if [[ ! $response =~ "No packages have known vulnerabilities" ]]; then
            echo "================================================================================"
            echo " $file"
            echo "================================================================================"
            echo
            echo "$response"
            echo
        fi
    done
done

debug "Finished."
