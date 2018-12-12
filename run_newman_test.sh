#! /usr/bin/env bash

# Pass the URL (no protocol) of the service to this script
# requires jq https://github.com/stedolan/jq

# Test for existance of tests folder
# Not all things will be testable with newman
# e.g. db setup, indexing

service=$1
url=$2

path="tests/services/wms/${service}"

if [ ! -f "${path}/data.json" ]
then
    echo "Test data not found, exiting..."
    exit 0
fi

# newman doesn't accept multiple data files yet
# process the json to add the service url
cat "${path}/data.json" \
    | jq --arg SERVICEURL "https://${url}" '[.[] | .path = $SERVICEURL]'\
    > "${service}.data.json"

newman run "${path}/postman_collection.json" -d ${service}.data.json
success="$?"
rm ${service}.data.json
exit "$success"

