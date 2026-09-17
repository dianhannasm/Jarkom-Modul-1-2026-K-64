#!/bin/bash

echo "Interface"
ip -br a

echo
echo "Nat Table"
iptables -t nat -L -v -n
