#!/bin/bash
# THis script adds (replaces) an _acme-challenge TXT record on godaddy for MYDOMAIN.
#set -x
if [[ $# -eq 0 || -z $1 ]] 
then
    echo "Must supply an acme challenge string as an argument. Exiting."
    exit -1
fi

# Support env variables as well as config file
[ -f ./ddns.conf ] && . ./ddns.conf

if [[ -z $GDAPIKEY || -z $MYDOMAIN || -z $GODADDYHOST ]]
then
    echo "Must supply GDAPIKEY, MYDOMAIN and GODADDYHOST in environment or ddns.conf file. Exiting."
    exit -2
fi

echo "Adding ACME challenge on GoDaddy"
resp=`curl -s -X PUT "${GODADDYHOST}/v1/domains/${MYDOMAIN}/records/TXT/_acme-challenge" -H "Authorization: sso-key ${GDAPIKEY}" -H "Content-Type: application/json" -d "[ {\"data\":\"$1\",\"name\":\"_acme-challenge\",\"port\":65535,\"ttl\":3600,\"type\":\"TXT\"} ]"`
echo "Added _acme_challenge $1 to ${MYDOMAIN}"
