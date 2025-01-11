#!/bin/bash

# Variables
DNS_DOMAIN="test.local"
DNS_IP="10.10.10.10"
DNS_PACKAGE="bind9"
NAMED_CONF="/etc/bind/named.conf.local"
ZONE_FILE="/etc/bind/db.test.local"

# Check if BIND9 is installed
if ! command -v named &>/dev/null; then
  echo "BIND9 is not installed. Installing BIND9..."
  apt update && apt install -y $DNS_PACKAGE
fi

# Configure BIND9 for the domain
if ! grep -q "$DNS_DOMAIN" "$NAMED_CONF"; then
  echo "Adding zone configuration for $DNS_DOMAIN..."
  cat <<EOF >> $NAMED_CONF
zone "$DNS_DOMAIN" {
    type master;
    file "$ZONE_FILE";
};
EOF
fi

# Create the zone file
if [ ! -f "$ZONE_FILE" ]; then
  echo "Creating zone file for $DNS_DOMAIN..."
  cat <<EOF > $ZONE_FILE
;
; BIND data file for $DNS_DOMAIN
;
\$TTL    604800
@       IN      SOA     ns.$DNS_DOMAIN. root.$DNS_DOMAIN. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.$DNS_DOMAIN.
ns      IN      A       $DNS_IP
@       IN      A       $DNS_IP
EOF
fi

# Set correct permissions
chmod 644 $ZONE_FILE
chown root:bind $ZONE_FILE

# Restart BIND9 service
echo "Restarting BIND9 service..."
systemctl restart bind9
