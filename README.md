# Godaddy scripts

A collection of bash scripts to manage godaddy records remotely.

Requires that curl be installed.

The ddns.conf file is of the form:

otegdapikey="Your OTE GoDaddy API key"
gdapikey="Your GoDaddy API key"
mydomain="Your domain name"

The following files are supplied:

ddns-a.sh - Updates godaddy A record if different than your external IP
ddns-cname.sh - Adds a godaddy CNAME record for the local host
ddns-acme.sh {ACME challenge} - Adds an ACME challenge record
