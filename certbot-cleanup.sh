#!/bin/bash
# This script delete all _acme-challenge TXT records on godaddy for GDDOMAIN.
#set -x
if [[ -z $CERTBOT_DOMAIN ]]
then
    echo "Must supply an CERTBOT_DOMAIN environment variable. Exiting."
    exit -1
fi

GDDOMAIN=$(expr match "$CERTBOT_DOMAIN" '.*\.\(.*\..*\)')

# Support env variables as well as config file
# Check the args
if [[ -z $GDAPIKEY ]]
then
    echo "Must supply GDAPIKEY in environment variable or ddns.conf file."
fi
fi
if [[ -z $GDHOST ]]
then
    echo "Must supply GDHOST, e.g. https://api.godaddy.com, in environment variable."
fi
# Terminate on missing args
if [[ -z $GDAPIKEY || -z $GDDOMAIN || -z $GDHOST ]]
then 
    echo "Exiting due to missing variables!"
    exit -2
fi

echo "Deleting ACME challenges for ${GDDOMAIN}on ${GDHOST}."
resp=`curl -s -X DELETE "${GDHOST}/v1/domains/${GDDOMAIN}/records/TXT/_acme-challenge" -H "Authorization: sso-key ${GDAPIKEY}" 
if grep -q "NOT_FOUND" <<< $resp ; then
    echo "Domain ${GDDOMAIN} does not appear to exist on ${GDHOST}. Exiting."
    exit -3
elif grep -q "UNABLE_TO_AUTHENTICATE" <<< $resp ; then
    echo "GDAPIKEY failed authentication. Exiting."
    exit -3
elif grep -q "RECORD_NOT_FOUND" <<< $resp ; then
    echo "No _acme-challenge records found."
fi
