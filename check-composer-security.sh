#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

# Parse options
if [ "${1:-}" = "-v" ]; then
    verbose=true
else
    verbose=false
fi

if [ -t 0 ]; then
    colors=
else
    colors=--no-ansi
fi

symfony="$HOME/.symfony/bin/symfony $colors"

# Helpers
debug() {
    if $verbose; then
        echo "$1"
    fi
}

install() {
    if [[ -f ~/.symfony/bin/symfony ]]; then
        debug "Updating Symfony console"
        $symfony self:update
    else
        debug "Installing Symfony console"
        curl -sS https://get.symfony.com/cli/installer | bash
    fi
}

check() {
    debug "Locating composer.lock files in ${1}..."
    for file in $(locate "$1/**/composer.lock" | grep -v /vendor/ | grep -v "^$1/.composer/"); do

        # Check using symfony security checker
        debug "Checking $file..."
        directory=$(dirname "$file")

        # ~/.symfony/bin/symfony security:check --dir=$directory
        response=$($symfony security:check --dir="$directory" || true)
        if [[ ! $response =~ "No packages have known vulnerabilities" ]]; then
            debug ""
           echo "================================================================================"
           echo " $file"
           echo "================================================================================"
           echo
           echo "$response"
           echo
        fi
    done
}

# install / update Symfony console if needed
install

# Loop through all the repo composer lock files for active users
debug "Looking for active accounts..."
for account in $(egrep -v ':(/bin/noshell|/bin/false|/sbin/nologin)$' /etc/passwd | cut -d: -f6 | grep ^/home/ | sort); do
    check "$account"
done

debug "Finished."
