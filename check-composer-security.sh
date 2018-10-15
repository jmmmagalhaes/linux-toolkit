#!/bin/bash
set -o nounset -o pipefail -o errexit

if [ "${1:-}" = "-v" ]; then
    verbose=true
else
    verbose=false
fi

debug() {
    if $verbose; then
        echo "$1"
    fi
}

# Loop through all the repo composer lock files for active users
debug "Looking for active accounts..."
for account in $(cat /etc/passwd | grep -v :/bin/noshell$ | grep -v :/bin/false$ | grep -v :/sbin/nologin | cut -d: -f6 | grep ^/home/ | sort); do

    debug "Locating composer.lock files in ${account}..."
    for file in $(locate $account/**/composer.lock | grep -v /vendor/ | grep -v "^$account/.composer/"); do

        # Check against sensiolabs
        debug "Checking $file..."
        response=$(curl -H 'Accept: text/plain' -s https://security.sensiolabs.org/check_lock -F lock=@$file)

        if [[ ! $response =~ .*"No known* vulnerabilities detected"* ]]; then
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
