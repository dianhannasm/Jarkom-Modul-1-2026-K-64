#!/bin/sh

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \ iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
