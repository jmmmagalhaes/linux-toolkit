#!/bin/bash

# List all error_log files on the server, sorted by largest first
locate -e --regexp "\/error_log$" | xargs du -h | sort -rh
