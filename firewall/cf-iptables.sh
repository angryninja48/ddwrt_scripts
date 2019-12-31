#!/bin/sh  -e

# Update DDWRT iptable rules based on cloudflares published IP blocks

# IP Prefixes used by CF
CF_URL_4="https://www.cloudflare.com/ips-v4"
CF_URL_6="https://www.cloudflare.com/ips-v6"

# DNAT internal IP
INGRESS_IP="10.20.0.50"

# Temporary files to store prefixes.
CF_TEMP_IP4="/tmp/cloudflare-ips-v4.txt"
CF_TEMP_IP6="/tmp/cloudflare-ips-v6.txt"

# Download prefixes
curl -k -s -o $CF_TEMP_IP4 $CF_URL_4
curl -k -s -o $CF_TEMP_IP6 $CF_URL_6

PREFIXES=$(cat $CF_TEMP_IP4)

# File to build iptable rules into
IPTABLES_RULES="/tmp/cf-iptables"
if [ ! -f "$IPTABLES_RULES" ]; then
    echo -e "#!/bin/sh\n" > $IPTABLES_RULES
    chmod a+x $IPTABLES_RULES
    # Loop through prefixes and append to file
    for PREFIX in $PREFIXES;
    do
      echo -e "iptables -t nat -I PREROUTING -p tcp -s $PREFIX -d $(nvram get wan_ipaddr) --dport 443 -j DNAT --to $INGRESS_IP:443\niptables -I FORWARD -p tcp -s $PREFIX -d $INGRESS_IP --dport 443 -j ACCEPT" >> $IPTABLES_RULES
    done
else
    echo -e "#!/bin/sh\n" > $IPTABLES_RULES
    for PREFIX in $PREFIXES;
    do
      echo -e "iptables -t nat -I PREROUTING -p tcp -s $PREFIX -d $(nvram get wan_ipaddr) --dport 443 -j DNAT --to $INGRESS_IP:443\niptables -I FORWARD -p tcp -s $PREFIX -d $INGRESS_IP --dport 443 -j ACCEPT" >> $IPTABLES_RULES
    done
fi

# Execute
$IPTABLES_RULES
