#!/bin/bash

target=$1

if [ -z "$target" ]; then
    echo "Usage: $0 <ip>"
    exit 1
fi

echo "[*] Full TCP scan..."

sudo nmap -p- --open -sS --min-rate 5000 -n -Pn $target -oG allPorts

ports=$(grep -oP '\d{1,5}/open' allPorts | cut -d '/' -f1 | tr '\n' ',' | sed 's/,$//')

if [ -z "$ports" ]; then
    echo "[!] No open ports found."
    exit 1
fi

echo "[*] Open ports: $ports"

echo "[*] Detailed scan..."

sudo nmap -sC -sV -p$ports $target -oN targeted
