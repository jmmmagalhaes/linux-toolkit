#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

curl -sS https://getcomposer.org/installer | php -d allow_url_fopen=On -- --install-dir=/usr/local/bin --filename=composer
