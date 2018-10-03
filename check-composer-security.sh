#!/bin/bash
set -o nounset -o pipefail -o errexit

## loop through all the repo composer lock files
for file in $(locate /home/**/repo/composer.lock)
do
    # check against sensiolabs
    response=$(curl -H "Accept: text/plain" -s https://security.sensiolabs.org/check_lock -F lock=@$file);

    if [[ ! $response =~ .*"No known* vulnerabilities detected"* ]]
    then
        echo '============================================================================================================='
        echo $file
        echo '============================================================================================================='
        echo
        echo $response
        echo
    fi
done