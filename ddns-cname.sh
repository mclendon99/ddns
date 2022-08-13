#!/bin/bash
#set -x
myhostname=`hostname -s`

. ddns.conf

if [[ -z $otegdapikey || -z $gdapikey || -z $mydomain ]]
then
    echo "Must supply otedgapikey gdapikey and mydomain in ddns.conf file"
    exit -2
fi
logdest="local7.info"

echo Hostname is $myhostname

dnsdata=`curl -s -X GET -H "Authorization: sso-key ${gdapikey}" "https://api.godaddy.com/v1/domains/${mydomain}/records/CNAME/${myhostname}"`
#dnsdata=`curl -s -X GET -H "Authorization: sso-key ${gdapikey}" "https://api.godaddy.com/v1/domains/${mydomain}/records"`
echo Response to CNAME query for ${myhostname}.${mydomain} is $dnsdata
if [ "[]" = "$dnsdata" ] ;
then
  echo "Adding a CNAME ${myhostname} record to domain ${mydomain}"
  resp=`curl -s -X PATCH  "https://api.godaddy.com/v1/domains/${mydomain}/records" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[ {\"data\":\"@\",\"name\":\"${myhostname}\",\"port\":65535,\"ttl\":3600,\"type\":\"CNAME\"} ]"`
  echo Response to add is $resp
fi


logger -p $logdest "Added CNAME record for ${hostname}.${mydomain}"
