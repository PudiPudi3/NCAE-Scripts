#!/bin/bash

# Set default policies to DROP
iptables -P INPUT DROP

# Allow loopback traffic (localhost)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow incoming SSH (port 22), DNS (port 53), FTP (port 21), MySQL (port 3306)
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 21 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 3306 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT

# Allow established and related connections for incoming traffic
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Outbound firewall configuration:
# Allow DNS queries
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow inbound traffic on passive mode data ports (50000-51000)
iptables -A INPUT -p tcp --dport 50000:51000 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 50000:51000 -j ACCEPT

# Allow outgoing SSH for remote administration
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

# Allow FTP passive mode data ports (usually ports 1024–65535)
iptables -A INPUT -p tcp --sport 1024:65535 --dport 1024:65535 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 20 --dport 1024:65535 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow outgoing connections to a specific database server (optional)
# Example: Replace 192.168.1.100 with the database server IP
# iptables -A OUTPUT -p tcp -d 192.168.1.100 --dport 3306 -j ACCEPT

# Allow all established and related outbound traffic
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Log dropped packets (optional)
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "IPTables-INPUT-DROP: " --log-level 4
iptables -A OUTPUT -m limit --limit 5/min -j LOG --log-prefix "IPTables-OUTPUT-DROP: " --log-level 4

echo "Firewall rules have been applied."
