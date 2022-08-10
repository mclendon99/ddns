#! /bin/sh
# This script is specifiic to GoDaddy, which only allows a single A record
# @ pointing to an ip address and all CNAME records must point to @
# without additional charges.
#set -x
myhostname=`hostname`
. ./ddns.conf

if [[ -z $otegdapikey || -z $gdapikey || -z $mydomain ]]
then
    echo "Must supply otedgapikey gdapikey and mydomain in ddns.conf file"
    exit -2
fi

logdest="local7.info"

myip=`curl -s "https://api.ipify.org"`
dnsdata=`curl -s -X GET -H "Authorization: sso-key ${gdapikey}" "https://api.godaddy.com/v1/domains/${mydomain}/records/A"`
gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
echo "`date '+%Y-%m-%d %H:%M:%S'` - Current External IP is $myip, GoDaddy DNS IP is $gdip"

if [ "$gdip" != "$myip" -a "$myip" != "" ]; then
  echo "IP has changed!! Updating on GoDaddy"
  curl -s -X PUT "https://api.godaddy.com/v1/domains/${mydomain}/records/A" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${myip}\"}]"
  logger -p $logdest "Changed IP on ${mydomain} from ${gdip} to ${myip}"
else
  echo "IP has not changed!!"
fi
