# Jarkom-Modul-1-2026-K-64  
Mahrinza Redouane Zakariyah  5027251074  
Dian Hanna Simanjuntak       5027251116
## Reporting

### Soal 1 - Konfigurasi Topologi dan IP Address  
<img width="739" height="422" alt="image" src="https://github.com/user-attachments/assets/a5b22b3a-d5f0-4104-9e9c-2cad64907d73" />  
  
Pembagian alamat IP:  
| Node    | Interface | IP Address     | Network        |
| ------- | --------- | -------------- | -------------- |
| Lain    | eth1      | 192.243.1.1/24 | 192.243.1.0/24 |
| Alice   | eth0      | 192.243.1.2/24 | 192.243.1.0/24 |
| Mika    | eth0      | 192.243.1.3/24 | 192.243.1.0/24 |
| Lain    | eth2      | 192.243.2.1/24 | 192.243.2.0/24 |
| Chisa   | eth0      | 192.243.2.2/24 | 192.243.2.0/24 |
| Lain    | eth3      | 192.243.3.1/24 | 192.243.3.0/24 |
| Knights | eth0      | 192.243.3.2/24 | 192.243.3.0/24 |
| Eiri    | eth0      | 192.243.3.3/24 | 192.243.3.0/24 |

**Konfigurasi Lain**  
```
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 192.243.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 192.243.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 192.243.3.1
    netmask 255.255.255.0
```
**Konfigurasi Alice**  
```
auto eth0
iface eth0 inet static
	address 192.243.1.2
	netmask 255.255.255.0
	gateway 192.243.1.1
```
**Konfigurasi Mika**  
```
auto eth0
iface eth0 inet static
	address 192.243.1.3
	netmask 255.255.255.0
	gateway 192.243.1.1
```
**Konfigurasi Chisa**  
```
auto eth0
iface eth0 inet static
	address 192.243.2.2
	netmask 255.255.255.0
	gateway 192.243.2.1
```
**Konfigurasi Knights**  
```
auto eth0
iface eth0 inet static
	address 192.243.3.2
	netmask 255.255.255.0
	gateway 192.243.3.1
```
**Konfigurasi Eiri**  
```
auto eth0
iface eth0 inet static
	address 192.243.3.3
	netmask 255.255.255.0
	gateway 192.243.3.1
```

### Soal 2 - Koneksi Lain ke Public Internet  
Pada Lain, interface eth0 dikonfigurasikan untuk mendapatkan alamat IP secara otomatis menggunakan DHCP:  
```
auto eth0
iface eth0 inet dhcp
```
Untuk memastikan Lain dapat terhubung ke internet, dilakukan pengujian:  
```
ping -c 4 8.8.8.8
```
Kemudian dilakukan pengujian DNS:  
```
ping -c 4 google.com
```  
<img width="482" height="275" alt="image" src="https://github.com/user-attachments/assets/36ddb7b2-f802-41f8-bba8-188b973d7dc9" />  

### Soal 3 - Routing Antarjaringan  
IP forwarding pada Lain diaktifkan menggunakan:  
```
sysctl -w net.ipv4.ip_forward=1
```
Lalu dicek:  

<img width="482" height="155" alt="image" src="https://github.com/user-attachments/assets/81f14282-6d33-4fdf-b049-ce1a0472d3c8" />  

Contoh dari Alice:  
```
ping -c 4 192.243.2.2
ping -c 4 192.243.3.2
ping -c 4 192.243.3.3
```

<img width="485" height="341" alt="image" src="https://github.com/user-attachments/assets/fd38782e-e39c-43e0-9461-a4085e81b0c0" />
  
### Soal 4 - NAT dan DNS Resolver  
Pertama, IP forwarding pada Lain dipastikan aktif:  
```
sysctl -w net.ipv4.ip_forward=1
```
Kemudian dibuat aturan NAT menggunakan MASQUERADE:  
```
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```
Untuk memeriksa aturan NAT:  
```
iptables -t nat -L -v -n
```
Selanjutnya client diuji untuk memastikan dapat mengakses internet.  
<img width="482" height="76" alt="image" src="https://github.com/user-attachments/assets/85951c1e-e83a-43c6-81d5-788116654dfb" />

### Soal 5 - Persistensi Konfigurasi  
Pada node Lain, dibuat script `init.sh` di dalam direktori `/root`:  

<img width="481" height="374" alt="image" src="https://github.com/user-attachments/assets/cd4ffa20-0678-4743-b036-f9950ae661b4" />  

### Soal 7 - Konfigurasi FTP Server pada Chisa  
Membuat FTP server pada node Chisa menggunakan vsFTPd dengan direktori `/var/wired/data`, kemudian mengatur hak akses:  
- Alice → dapat membaca dan menulis file.  
- Mika → hanya dapat membaca file.  
- Eiri → tidak diperbolehkan mengakses FTP.  

Install vsFTPd  
Pada node Chisa:  
```
apk update
apk add vsftpd
```
<img width="482" height="112" alt="image" src="https://github.com/user-attachments/assets/1f820145-3162-4dd5-aa5e-10ef5f29ad4f" />  
  
Buat direktori FTP, user, group, dan set passwaord.  
```
mkdir -p /var/wired/data

adduser -D alice
adduser -D mika
adduser -D eiri

addgroup ftpusers
addgroup mika ftpusers

passwd alice
passwd mika
passwd eiri
```

<img width="480" height="67" alt="image" src="https://github.com/user-attachments/assets/dbcf6f25-4395-4871-862e-584e837d0317" />

Lalu permission direktori  
```
chown alice:ftpusers /var/wired/data
chmod 750 /var/wired/data
```

Lalu config vsFTPD  
```
cat > /etc/vsftpd/vsftpd.conf <<'EOF'
listen=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES

local_umask=022
chroot_local_user=YES
allow_writeable_chroot=YES

local_root=/var/wired/data

userlist_enable=YES
userlist_deny=YES
userlist_file=/etc/vsftpd.userlist

pasv_min_port=40000
pasv_max_port=40100

seccomp_sandbox=NO
EOF
```

Lalu buat blacklist Eiri:  
```
echo "eiri" > /etc/vsftpd.userlist
```

Set PAM supaya user yang ada di blacklist ditolak:  
```
cat > /etc/pam.d/vsftpd <<'EOF'
auth required pam_listfile.so item=user sense=deny file=/etc/vsftpd.userlist onerr=succeed
auth required pam_unix.so
account required pam_unix.so
EOF
```

1. Tes Alice - harus bisa upload
   <img width="895" height="201" alt="image" src="https://github.com/user-attachments/assets/fbe540cc-f109-4ba3-8b3c-f0cba2992ebc" />

3. Tes Mika - harus bisa baca/download
   <img width="885" height="139" alt="image" src="https://github.com/user-attachments/assets/d7df5a55-c011-4507-a60a-e1610cd895fb" />

5. Tes Eiri - harus ditolak  
   <img width="514" height="133" alt="image" src="https://github.com/user-attachments/assets/69b1899a-e261-4a43-90f8-7276349b3c09" />

### Soal 9 -
