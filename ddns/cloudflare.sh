#!/bin/sh  -e

# Use Cloudflare API to get ids - https://api.cloudflare.com
# ZONE = curl -X GET "https://api.cloudflare.com/client/v4/zones"     -H "X-Auth-Email: jonbaker85@gmail.com" -H "X-Auth-Key: $AUTH_KEY" -H "Content-Type: application/json"
# RECORD = curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records"     -H "X-Auth-Email: jonbaker85@gmail.com"     -H "X-Auth-Key: $AUTH_KEY" -H "Content-Type: application/json"


AUTH_EMAIL=jonbaker85@gmail.com
AUTH_KEY="" #API Global Token
ZONE_ID=""
A_RECORD_NAME="test"
A_RECORD_ID=""

# Retrieve the last recorded public IP address
IP_RECORD="/tmp/ip-record"
if [ ! -f "$IP_RECORD" ]; then
    touch /tmp/ip-record
fi

RECORDED_IP=$(cat $IP_RECORD)

# Fetch the current public IP address
PUBLIC_IP=$(curl -s ifconfig.co)

#If the public ip has not changed, nothing needs to be done, exit.
if [ "$PUBLIC_IP" = "$RECORDED_IP" ]; then
    exit 0
fi

# Otherwise, your Internet provider changed your public IP again.
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
curl -s -k "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$A_RECORD_ID" \
     -X PUT \
     -H "Content-Type: application/json" \
     -H "X-Auth-Email: $AUTH_EMAIL" \
     -H "X-Auth-Key: $AUTH_KEY" \
     -d "$RECORD" >> /tmp/cf-dns-update.log
