#!/bin/bash
# This script adds (replaces) an _acme-challenge TXT record on godaddy for MYDOMAIN.
#set -x
if [[ $# -eq 0 || -z $1 ]] 
then
    echo "Must supply an acme challenge string as an argument. Exiting."
    exit -1
fi

# Support env variables as well as config file
[ -f ./ddns.conf ] && . ./ddns.conf
# Check the args
if [[ -z $GDAPIKEY ]]
then
    echo "Must supply GDAPIKEY in environment variable or ddns.conf file."
fi
if [[ -z $GODADDDYDOMAIN ]]
then
    echo "Must supply MYDOMAIN in environment variable or ddns.conf file."
fi
if [[ -z $GODADDYHOST ]]
then
    echo "Must supply GODADDYHOST in environment variable or ddns.conf file."
fi
# Terminate on missing args
if [[ -z $GDAPIKEY || -z $GODADDDYDOMAIN || -z $GODADDYHOST ]]
then 
    echo "Exiting due to missing variables!"
    exit -2
fi


echo "Adding ACME challenge on GoDaddy"
resp=`curl -s -X PUT "${GODADDYHOST}/v1/domains/${GODADDDYDOMAIN}/records/TXT/_acme-challenge" -H "Authorization: sso-key ${GDAPIKEY}" -H "Content-Type: application/json" -d "[ {\"data\":\"$1\",\"name\":\"_acme-challenge\",\"port\":65535,\"ttl\":3600,\"type\":\"TXT\"} ]"`
if grep -q "NOT_FOUND" <<< $resp ; then
    echo "Domain ${GODADDDYDOMAIN} does not appear to exist on GoDaddy. Exiting."
    exit -3
elif grep -q "UNABLE_TO_AUTHENTICATE" <<< $resp ; then
    echo "GDAPIKEY failed authentication. Exiting."
    exit -3
fi
# External IP
echo "Added _acme_challenge $1 to ${GODADDDYDOMAIN}"
