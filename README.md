# DDWRT Scripts

## DDNS

Used to update cloudflare's DNS with the router's public IP address on a reboot.

* cloudflare.sh - Updates the cloudflare API
* ddns.wanup - Executes the cloudflare script once the wan is up **(/jffs/etc/config/\*.wanup)**. Also creates a cron job to run the script every hour.

More info on script execution: https://wiki.dd-wrt.com/wiki/index.php/Script_Execution

## CACERT

Updates Root CA Certs every month

## Firewall

* cf-iptables - Downloads Cloudflare's published IP blocks and adds an inbound rule on DDWRT using iptables
