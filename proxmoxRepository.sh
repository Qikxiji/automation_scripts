#!/usr/bin/env bash

#security flags
set -eu

#disable entertprice repository (comment)
sed -i 's/^/#/' /etc/apt/sources.list.d/pve-enterprise.list

echo "disable enterprice repository succeed..."
#create source list with free no-subscribe repository.
#actual link on repository in official documentation:
#https://pve.proxmox.com/wiki/Package_Repositories#sysadmin_no_subscription_repo
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" \
     > /etc/apt/sources.list.d/pve-no-subscribe.list

echo "enable free no-subscribe repository succeed..."
#disable "no subscribe" notification that appears during the launch of the web interface/ make .bak file
#change 565 str of proxmoxlib.js document:
#.data.status.toLowerCase() !== 'active') {
#to
#.data.status.toLowerCase() == 'active') {
sed -i.bak 's/!== '\''active'\'') {/== '\''active'\'') {/' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js

echo "disable "no subscribe" notification succeed!"

#restart the proxmox service.
echo "reloading pveproxy.service..."
systemctl restart pveproxy.service
echo "Finish succeed!"
