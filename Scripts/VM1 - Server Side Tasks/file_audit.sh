#!/bin/bash

sudo apt install inotify-tools

directory="/projects/development"
logFile="/var/log/file_changes.log"

# Make sure the log file exists
sudo touch $logFile

echo "Monitoring $directory for file changes..."

# Start monitoring
inotifywait -m -r -e create -e modify -e delete --format '%e %w%f' "$directory" | while read event file
do
    # Log the event
    echo "User: $(whoami) | Action: $event | File: $file" >> "$logFile"
done

# Make sure this is run with user that has access to logFile and directory, otherwise use sudo ./file_audit.sh to run
