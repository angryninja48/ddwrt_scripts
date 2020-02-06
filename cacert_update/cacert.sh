#!/bin/sh -e

CERTDIR="/jffs/ssl/certs"
CACERT="$CERTDIR"/cacert.pem

if [ -f "$CACERT" ]; then
    curl -k -s -m 30 -o $CACERT https://curl.haxx.se/ca/cacert.pem
else
    mkdir -p $CERTDIR
    curl -k -s -m 30 -o $CACERT https://curl.haxx.se/ca/cacert.pem
fi
