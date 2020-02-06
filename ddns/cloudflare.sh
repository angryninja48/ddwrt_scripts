#!/bin/sh -e

# Authentication and Record details
# Use Cloudflare API to get ids - https://api.cloudflare.com
# ZONE = curl -X GET "https://api.cloudflare.com/client/v4/zones"     -H "X-Auth-Email: jonbaker85@gmail.com" -H "X-Auth-Key: $AUTH_KEY" -H "Content-Type: application/json"
# RECORD = curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records"     -H "X-Auth-Email: jonbaker85@gmail.com"     -H "X-Auth-Key: $AUTH_KEY" -H "Content-Type: application/json"

AUTH_EMAIL=jonbaker85@gmail.com
AUTH_KEY="" #API Global Token
ZONE_ID=""
A_RECORD_NAME="test"
A_RECORD_ID=""


# SSL CA Cert bundle - https://curl.haxx.se/ca/cacert.pem
# Curl can throw an error about untrusted certs if using an older version

export SSL_CERT_FILE="/jffs/ssl/certs/cacert.pem"

# Retrieve the last recorded public IP address
IP_RECORD="/tmp/ip-record"
if [ ! -f "$IP_RECORD" ]; then
    touch /tmp/ip-record
fi

RECORDED_IP=$(cat $IP_RECORD)

# Fetch the current public IP address
# Limit to 10 retries
count=0
while [[ -z "$PUBLIC_IP" && $count -lt 10 ]]; do
   PUBLIC_IP=$(curl -s ifconfig.co)
   count=`expr $count + 1`;
   echo $(date) - "IP Address fetch attempt number # $count"
   sleep 2;
done

# Log out whether we got an IP Address
if [ -z "$PUBLIC_IP" ]
then
   echo $(date) - "No Public IP Obtained"
else
   echo $(date) - "Public IP = $PUBLIC_IP"
fi

#If the public ip has not changed, nothing needs to be done, exit.
if [ "$PUBLIC_IP" = "$RECORDED_IP" ]; then
   echo $(date) - "IP Address has not changed - exiting"
   exit 0
fi

# Record the new public IP address locally
echo $PUBLIC_IP > $IP_RECORD

# Record the new public IP address on Cloudflare using API v4
RECORD=$(cat <<EOF
{ "type": "A",
  "name": "$A_RECORD_NAME",
  "content": "$PUBLIC_IP",
  "proxied": true }
EOF
)

echo $(date) - "Updating Cloudflare DNS";

curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$A_RECORD_ID" \
     -X PUT \
     -H "Content-Type: application/json" \
     -H "X-Auth-Email: $AUTH_EMAIL" \
     -H "X-Auth-Key: $AUTH_KEY" \
     -d "$RECORD" >> /tmp/var/log/cloudflare.logi 2>&1;

echo $(date) - "Cloudflare Updated!";
