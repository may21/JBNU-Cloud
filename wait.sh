#!/bin/bash

# This script monitors the OpenStack image queue and waits until all images have completed processing.
# It continuously checks for images with the status 'queued' and exits when none are found.
# The script outputs timestamps when it starts and when the process is complete.

# Output the current date and time when the script starts
echo "$(date +%m-%d-%H-%M-%S)"

# Start an infinite loop to monitor the image queue
while true; do
    # Alternative debug message (commented out)
    # echo "1"

    # Retrieve the list of images with status 'queued' from OpenStack
    string="$(openstack image list --status queued)"

    # Alternative debug message to display the retrieved string (commented out)
    # echo "$string"

    # Check if the string is empty (no images with status 'queued')
    if [[ -z "$string" ]]; then
        # Output the current date and time when processing is complete
        echo "$(date +%m-%d-%H-%M-%S)"
        
        # Output completion message
        echo "DONE!! Do next Job"
        
        # Exit the script as there are no more queued images
        exit
    elif [[ -n "$string" ]]; then
        # If there are images still in 'queued' status, wait for 1 second
        sleep 1
    fi
done
