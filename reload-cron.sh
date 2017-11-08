#!/bin/bash

# Run this after modifying any files in ./cron.d/ because inotify doesn't watch symlink targets
exec killall -HUP crond
