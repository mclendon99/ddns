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
    echo "Must supply GDAPIKEY in environment variable or ddns.conf file. Exiting."
    exit -2
fi
if [[ -z $MYDOMAIN ]]
then
    echo "Must supply MYDOMAIN in environment variable or ddns.conf file. Exiting."
    exit -2
fi
if [[ -z $GODADDYHOST ]]
then
    echo "Must supply GODADDYHOST in environment variable or ddns.conf file. Exiting."
    exit -2
fi
# Check the domain exists
resp=`curl -s -X GET "${GODADDYHOST}/v1/domains/${MYDOMAIN}"  -H "Authorization: sso-key ${GDAPIKEY}"`
if grep -q "NOT_FOUND" <<< $resp ; then
    echo "Domain ${MYDOMAIN} does not appear to exist on GoDaddy. Exiting."
    exit -3
fi
# External IP
myip=`curl -s "https://api.ipify.org"`
dnsdata=`curl -s -X GET -H "Authorization: sso-key ${GDAPIKEY}" "${GODADDYHOST}/v1/domains/${MYDOMAIN}/records/A"`
echo "Response is - "$dnsdata
gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
echo "`date '+%Y-%m-%d %H:%M:%S'` - Current external IP is $myip. GoDaddy DNS IP is $gdip."

if [[ "$gdip" != "$myip" && "$myip" != "" ]]; then
  echo "IP has changed! Updating on GoDaddy..."
  resp=`curl -s -X PUT "${GODADDYHOST}/v1/domains/${MYDOMAIN}/records/A/@" -H "Authorization: sso-key ${GDAPIKEY}" -H "Content-Type: application/json" -d "[ {\"data\":\"${myip}\",\"name\":\"@\",\"port\":65535,\"ttl\":3600,\"type\":\"A\"} ]"`
  echo "Response is: ${resp}"
  echo "Changed A record IP on ${MYDOMAIN} from ${gdip} to ${myip}."
else
  echo "IP has not changed! No action taken."
fi
