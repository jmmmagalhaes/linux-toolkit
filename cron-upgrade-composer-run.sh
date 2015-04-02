#!/bin/bash

if which php-cli >/dev/null 2>&1; then
    # On CentOS the CGI version is the default not CLI
    bin=php-cli
else
    bin=php
fi

exec $bin /usr/local/bin/composer self-update -q
