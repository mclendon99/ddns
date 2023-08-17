#!/bin/bash
# This script adds an _acme-challenge TXT record on godaddy for GDDOMAIN.
#set -x
if [[ -z $CERTBOT_DOMAIN ]]
then
    echo "Must supply an CERTBOT_DOMAIN environment variable. Exiting."
    exit -1
fi
if [[ -z $CERTBOT_VALIDATION ]]
then
    echo "Must supply a CERTBOT_VALIDATION environment variable. Exiting."
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


echo "Adding ACME challenge on GoDaddy."
resp=`curl -s -X PATCH "${GDHOST}/v1/domains/${GDDOMAIN}/records" -H "Authorization: sso-key ${GDAPIKEY}" -H "Content-Type: application/json" -d "[ {\"data\":\"${CERTBOT_VALIDATION}\",\"name\":\"_acme-challenge\",\"port\":65535,\"ttl\":3600,\"type\":\"TXT\"} ]"`
if grep -q "NOT_FOUND" <<< $resp ; then
    echo "Domain ${GDDOMAIN} does not appear to exist on ${GDHOST}. Exiting."
    exit -3
elif grep -q "UNABLE_TO_AUTHENTICATE" <<< $resp ; then
    echo "GDAPIKEY failed authentication. Exiting."
    exit -3
fi
# External IP
echo "Added _acme_challenge $1 to ${GDDOMAIN}"
sleep 15
