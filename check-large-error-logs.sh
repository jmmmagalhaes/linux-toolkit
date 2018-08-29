#!/bin/bash

echo 'List of error_log files larger than 1MB:'

# List all error_log files on the server, sorted by largest first
locate error_log | xargs du -h -t 1MB | sort -rh