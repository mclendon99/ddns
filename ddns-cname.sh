#!/bin/bash
#set -x
# Add a CNAME record for a host if one is not already present.

# Support env variables as well as config file
[ -f ./ddns.conf ] && . ./ddns.conf

if [[ -z $GDAPIKEY || -z $MYDOMAIN || -z $GODADDYHOST ]]
then
    echo "Must supply GDAPIKEY, MYDOMAIN and GODADDYHOST in environment variables or ddns.conf file. Exiting."
    exit -2
fi
# Check the domain exists
resp=`curl -s -X GET "${GODADDYHOST}/v1/domains/${MYDOMAIN}"  -H "Authorization: sso-key ${GDAPIKEY}"`
if grep -q "NOT_FOUND" <<< $resp ; then
    echo "Domain ${MYDOMAIN} does not appear to exist on GoDaddy. Exiting."
    exit -3
fi

# Just the host part
myhostname=`hostname -s`
echo Host name is $myhostname

dnsdata=`curl -s -X GET -H "Authorization: sso-key ${GDAPIKEY}" "${GODADDYHOST}/v1/domains/${MYDOMAIN}/records/CNAME/${myhostname}"`
echo Response to CNAME query for ${myhostname}.${MYDOMAIN} is $dnsdata
if [ "[]" = "$dnsdata" ] ; then
  echo "Adding a CNAME ${myhostname} record to domain ${MYDOMAIN}"
  resp=`curl -s -X PATCH  "${GODADDYHOST}/v1/domains/${MYDOMAIN}/records" -H "Authorization: sso-key ${GDAPIKEY}" -H "Content-Type: application/json" -d "[ {\"data\":\"@\",\"name\":\"${myhostname}\",\"port\":65535,\"ttl\":3600,\"type\":\"CNAME\"} ]"`
  echo Response to PATCH is: $resp
  echo "Added CNAME record for ${hostname}.${MYDOMAIN}"
else
  echo CNAME record for ${myhostnmae} already exists. No action taken.
fi


