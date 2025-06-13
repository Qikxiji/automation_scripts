#!/usr/bin/env bash

#security flags
set -eu

#---------------------------------------
#define variables
#---------------------------------------

#path to iptables bin
IPTABLES="/sbin/iptables"

#define ssh port
MY_SSH_PORT="2222"

#---------------------------------------
#install and configure fail2ban for ssh
#---------------------------------------

#install if necessary
apt-get update
apt-get install fail2ban -y

#backup old user config if exist (aviod delete actual config)
if [[ -f "/etc/fail2ban/jail.local" ]]
then

  fileName=jail.local_$(date +"%F_%R").bak

  mkdir -p /etc/fail2ban/jail_backups/

  mv "/etc/fail2ban/jail.local" "/etc/fail2ban/jail_backups/$fileName"

fi

#create user config file
touch /etc/fail2ban/jail.local

#fill file with sshd config
cat <<EOF > /etc/fail2ban/jail.local
[sshd]
enable   = true
port     = $MY_SSH_PORT
logpath  = /var/log/auth.log
findtime = 5m
bantime  = 60m
maxretry = 5
EOF

#reload daemon
systemctl reload-or-restart fail2ban.service

#---------------------------------------
#configure iptables
#---------------------------------------
#install iptables-persistent for permanent storage and loading of rules
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install iptables-persistent -y

#delete all rules from default chains
$IPTABLES -F
$IPTABLES -t nat -F

#delete user chains
$IPTABLES -X
#set default policy for default chains
$IPTABLES -P FORWARD DROP
$IPTABLES -P INPUT DROP
$IPTABLES -P OUTPUT ACCEPT


#allow SSH traffic
$IPTABLES -A INPUT -p tcp --dport $MY_SSH_PORT -j ACCEPT

#allow HTTP traffic
$IPTABLES -A INPUT -p tcp --dport 80 -j ACCEPT

#allow HTTPS traffic
$IPTABLES -A INPUT -p tcp --dport 443 -j ACCEPT

#allow loopback
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A OUTPUT -o lo -j ACCEPT

#save rules (/etc/iptables/)
service netfilter-persistent save
