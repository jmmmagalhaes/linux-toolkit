#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

rm -i /etc/cron.d/forward-system-mail
