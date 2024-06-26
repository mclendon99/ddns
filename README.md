# GoDaddy scripts

A collection of bash scripts to manage godaddy records remotely.
Bash is required as the scripts use the `[[` operator.
*** N.B. Godaddy no longer allows Management and DNS API access unless you have 10 or more domains registered. Use CloudFLare instead. It's just easier.

The scripts require that curl be installed, e.g.

    sudo apt install curl

The ddns.conf file is of the form:

    # The GDAPIKEY consists of the key and the secret seperated by a colon, e.g. "key:secret"
    GDAPIKEY="Replace with your GoDaddy API key or GoDaddy OTE key if using the OTE."
    # The https:// prefix is required as part of the string.
    GDHOST=https://api.godaddy.com
    # Use this for testing on the OTE. Be sure to set the OTE key in GDAPIKEY if using the OTE.
    # GODADDYHOST=https://api.ote-godaddy.com
    # Replace with your domain as registered on GoDaddy (not the hostname part).
    GDDOMAIN=""

The configuration items can also be read from the environment. The config file items override the environment entries. An example ddns.conf.example file is included with this package.

The following scripts are supplied:

    * ddns-a.sh - Updates the godaddy A record if different than your external IP. The script takes no arguments.

    * ddns-cname.sh - Adds a godaddy CNAME record for the local host if not already present. The CNAME record points to the domain. The script takes no arguments. Suppresses the "unsafe to continue" warning from web browsers using HTTPS.  
                
    * ddns-acme.sh - Adds an ACME challenge TXT record. The mandatory challenge is passed in as an argument to the script. The operator is responsible for cleaning up the TXT records after validation.
