#!/bin/bash
#set -x
myhostname=`hostname`
myip=`ifconfig wlan0 | grep "inet " |awk '{ print $2 }'`

. ddns.conf

if [[ -z $otegdapikey || -z $gdapikey || -z $mydomain ]]
then
    echo "Must supply otedgapikey gdapikey and mydomain in ddns.conf file"
    exit -2
fi
logdest="local7.info"

#myip=`curl -s "https://api.ipify.org"`
dnsdata=`curl -s -X GET -H "Authorization: sso-key ${gdapikey}" "https://api.godaddy.com/v1/domains/${mydomain}/records/CNAME/${myhostname}.${mydomain}"`
gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
echo "`date '+%Y-%m-%d %H:%M:%S'` - Current External IP is $myip, GoDaddy DNS IP is $gdip"

echo "Adding a CNAME ${myhostname} record to domain ${mydomain}"
curl -s -X PUT "https://api.godaddy.com/v1/domains/${mydomain}/records/CNAME/${myhostname}.${mydomain}" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${myip}\"}]"
logger -p $logdest "Changed IP on ${hostname}.${mydomain} from ${gdip} to ${myip}"
