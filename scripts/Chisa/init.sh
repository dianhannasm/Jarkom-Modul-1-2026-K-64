#!/bin/sh

echo "nameserver 8.8.8.8" > /etc/resolv.conf

mkdir -p /var/wired/data

chown alice:ftpusers /var/wired/data
chmod 750 /var/wired/data

if ! pgrep vsftpd >/dev/null 2>&1; then
    /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf &
fi