#!/bin/bash

# This script is used to create disks. An idealized version of this script would
# look at the env/*.yaml for the gcePersistentDisks and make sure that all of
# them are created. It makes sure that the labels are added appropriately

ZONE=us-central1-c
DISK_NAME="$1"
if [[ -z "$DISK_NAME" ]]; then
    exit 1
fi

gcloud compute disks create "$DISK_NAME" \
    --labels=helm=sequencer --type=pd-ssd --zone=$ZONE --size=200G
