#! /bin/bash
# This script is specific to GoDaddy, which only allows a single A record
# @ pointing to an IP address and all CNAME records must point to the single domain
# without incurring additional charges.
#set -x

# Support env variables as well as config file
[ -f ./ddns.conf ] && . ./ddns.conf

if [[ -z $GDAPIKEY || -z $MYDOMAIN || -z $GODADDYHOST ]]
then
    echo "Must supply GDAPIKEY, MYDOMAIN and GODADDYHOST variables in environment variables or ddns.conf file. Exiting."
    exit -2
fi

myhostname=`hostname -s`
# External IP
myip=`curl -s "https://api.ipify.org"`
dnsdata=`curl -s -X GET -H "Authorization: sso-key ${GDAPIKEY}" "${GODADDYHOST}/v1/domains/${MYDOMAIN}/records/A"`
gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
echo "`date '+%Y-%m-%d %H:%M:%S'` - Current External IP is $myip. GoDaddy DNS IP is $gdip."

if [[ "$gdip" != "$myip" && "$myip" != "" ]]; then
  echo "IP has changed!! Updating on GoDaddy"
  curl -s -X PUT "${GODADDYHOST}/v1/domains/${MYDOMAIN}/records/A/@" -H "Authorization: sso-key ${GDAPIKEY}" -H "Content-Type: application/json" -d "[ {\"data\":\"${myip}\",\"name\":\"@\",\"port\":65535,\"ttl\":3600,\"type\":\"A\"} ]"
  echo "Changed A record IP on ${MYDOMAIN} from ${gdip} to ${myip}."
else
  echo "IP has not changed! No action taken."
fi
