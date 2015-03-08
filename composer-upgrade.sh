#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

exec /usr/local/bin/composer self-update
