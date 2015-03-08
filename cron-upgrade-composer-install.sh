#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

ln -s $PWD/cron.d/upgrade-composer /etc/cron.d/
