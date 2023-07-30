#! /bin/bash
# This script is specific to GoDaddy, which only allows a single A record
# @ pointing to an IP address and all CNAME records must point to the single domain
# without incurring additional charges.
#set -x

# Support env variables as well as config file
# Config file, if it exists, overrides the env variables
[ -f ./ddns.conf ] && . ./ddns.conf

if [[ -z $GDAPIKEY ]]
then
    echo "Must supply GDAPIKEY in environment variable or ddns.conf file."
fi
if [[ -z $GDDOMAIN ]]
then
    echo "Must supply MYDOMAIN in environment variable or ddns.conf file."
fi
if [[ -z $GDHOST ]]
then
    echo "Must supply GODADDYHOST in environment variable or ddns.conf file."
fi
# Terminate if anything missing
if [[ -z $GDAPIKEY || -z $GDDOMAIN || -z $GDHOST ]]
then 
    echo "Exiting due to missing variables!"
    exit -2
fi

# Check the domain exists
echo "Checking domain: ${GODADDYDOMAIN}"
resp=`curl -s -X GET "${GODADDYHOST}/v1/domains/${GODADDYDOMAIN}"  -H "Authorization: sso-key ${GDAPIKEY}"`
if grep -q "NOT_FOUND" <<< $resp ; then
    echo "Domain ${GODADDYDOMAIN} does not appear to exist on GoDaddy. Exiting."
    exit -3
elif grep -q "UNABLE_TO_AUTHENTICATE" <<< $resp ; then
    echo "GDAPIKEY failed authentication. Exiting."
    exit -3
fi
# External IP
echo "Retrieving A record"
myip=`curl -s "https://api.ipify.org"`
dnsdata=`curl -s -X GET -H "Authorization: sso-key ${GDAPIKEY}" "${GODADDYHOST}/v1/domains/${GODADDYDOMAIN}/records/A"`
echo "Response is - "$dnsdata
gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
echo "`date '+%Y-%m-%d %H:%M:%S'` - Current external IP is $myip. GoDaddy DNS IP is $gdip."

if [[ "$gdip" != "$myip" && "$myip" != "" ]]; then
  echo "IP has changed! Updating on GoDaddy..."
  resp=`curl -s -X PUT "${GODADDYHOST}/v1/domains/${GODADDYDOMAIN}/records/A/@" -H "Authorization: sso-key ${GDAPIKEY}" -H "Content-Type: application/json" -d "[ {\"data\":\"${myip}\",\"name\":\"@\",\"port\":65535,\"ttl\":3600,\"type\":\"A\"} ]"`
  echo "Response to PUT is: ${resp}"
  echo "Changed A record IP on ${GODADDYDOMAIN} from ${gdip} to ${myip}."
else
  echo "IP has not changed! No action taken."
fi
