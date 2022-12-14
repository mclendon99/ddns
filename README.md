# GoDaddy scripts

A collection of bash scripts to manage godaddy records remotely.
Bash is required as the scripts use the [[ operator.

Requires that curl be installed. (sudo apt-get install curl)

The ddns.conf file is of the form:

GDAPIKEY="Replace with your GoDaddy API key or GoDaddy OTE key if using the OTE."
# `The https part is required as part of the string.
GODADDYHOST=https://api.godaddy.com
# or this for testing on the OTE. Be sure to set the OTE key in GDAPIKEY if using the OTE.
#GODADDYHOST=https://api.ote-godaddy.com
MYDOMAIN="Replace with your domain name (just the domain part - not the host part)."

The configuration items can also be read from the environment. The config file items 
override the environment entries.

The following scripts are supplied:

* ddns-a.sh - Updates the godaddy A record if different than your external IP. 
              The script takes no arguments.
* ddns-cname.sh - Adds a godaddy CNAME record for the local host if not already present. 
                The CNAME record points to the domain.  The script takes no arguments.
                Suppresses the "unsafe to continue" warning from web browsers using HTTPS.
* ddns-acme.sh - Adds or replaces an ACME challenge record. THe challenge is passed in as 
                 an argument to the script.
