#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

cd cron.d/

for file in *; do
    link=/etc/cron.d/$file

    if [ -f $link ]; then
        rm -i $link
    fi
done

../reload-cron.sh

echo "All done."
