#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

rm -i /usr/local/bin/composer || exit
rm -f /etc/cron.d/upgrade-composer
