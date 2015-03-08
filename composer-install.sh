#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

# The 'tail' part strips the '#!/usr/bin/env php' line
curl -sS https://getcomposer.org/installer | tail -n +2 | php -- --install-dir=/usr/local/bin --filename=composer

# Install cron job too?
source bash/ask.sh

echo
if ask "Install cron job to upgrade Composer daily?" Y; then
    ./cron-upgrade-composer-install.sh
fi
