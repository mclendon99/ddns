#!/bin/bash
#set -x
if [[ $# -eq 0 || -z $1 ]] 
then
    echo "Must supply acme challenge string as an argument"
    exit -1
fi

. ddns.conf

if [[ -z $otegdapikey || -z $gdapikey || -z $mydomain ]]
then
    echo "Must supply otedgapikey gdapikey and mydomain in ddns.conf file"
    exit -2
fi

myhostname=`hostname`
myip=`ifconfig wlan0 | grep "inet " | awk '{ print $2 }'`
if [ -z $myip ] 
then
    myip=`ifconfig wlan1 | grep "inet " | awk '{ print $2 }'`
fi

logdest="local7.info"

#myip=`curl -s "https://api.ipify.org"`
dnsdata=`curl -s -X GET -H "Authorization: sso-key ${gdapikey}" "https://api.godaddy.com/v1/domains/${mydomain}/records/CNAME/${myhostname}.${mydomain}"`
gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
echo "`date '+%Y-%m-%d %H:%M:%S'` - Current External IP is $myip, GoDaddy DNS IP is $gdip"

if [ "$gdip" != "$myip" -a "$myip" != "" ]; then
  echo "IP has changed!! Updating on GoDaddy"
  curl -s -X PUT "https://api.godaddy.com/v1/domains/${mydomain}/records/TXT/_acme_challenge" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${myip}\"}]"
  logger -p $logdest "Added _acme_challenge $1 to ${mydomain}"
fi
