#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

source bash/ask.sh

cd cron.d/

for file in *; do
    link=/etc/cron.d/$file
    target=$PWD/$file

    if [ -L $link ]; then
        continue
    fi

    if [ -f $link ]; then
        ask "Overwrite file $link?" || continue
    else
        ask "Create symlink at $link?" || continue
    fi

    ln -snf $target $link
done

../reload-cron.sh

echo "All done."
