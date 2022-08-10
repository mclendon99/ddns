A collection of bash scripts to manage godaddy remotely

The ddns.conf file is on the form:

otegdapikey="Your OTE GoDaddy API key"
gdapikey="Your GoDaddy API key"
mydomain="Your domain name"

ddns-a.sh - Updates godaddy A record if different than your external IP
ddns-cname.sh - Updates godaddy cname if different than external IP
ddns-acme.sh {ACME challenge} - Adds an ACME challenge record
