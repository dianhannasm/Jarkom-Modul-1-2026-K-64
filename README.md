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

### Soal 9 - Mika
Di Chisa, buat `protocol7_manifesto.txt`:  
```
nano /var/wired/data/protocol7_manifesto.txt

chown alice:ftpusers /var/wired/data/protocol7_manifesto.txt
chmod 644 /var/wired/data/protocol7_manifesto.txt
```
Dari Mika, download file.  
```
get protocol_manifesto.txt
```
Kemudian, coba upload sebagai Mika, buat file dummy dan coba untuk download.  
```
echo "Mika upload test" > mika_test.txt

put mika_test.txt
```

<img width="961" height="244" alt="image" src="https://github.com/user-attachments/assets/41ee5335-d3ab-46fb-b026-d99fa62418ea" />

### Soal 12 - Alice ke Knights  
Targetnya:  
| Port | Kondisi | Yang harus terlihat |
| ---- | ------- | ------------------- |
| 22   | Open    | `SYN → SYN-ACK`     |
| 80   | Open    | `SYN → SYN-ACK`     |
| 7777 | Closed  | `SYN → RST-ACK`     |

Dari Knights, Install SSH + web server dan aktifkan  
```
apk update
apk add openssh nginx

ssh-keygen -A
/usr/sbin/sshd
nginx
```

<img width="481" height="69" alt="image" src="https://github.com/user-attachments/assets/68109dc4-33d7-48a1-8e6d-78fe206f2d39" />
  
Dari Alice, cek port 22, 80, dan 7777  
```
nc -zv 192.243.3.2 22

nc -zv 192.243.3.2 80

nc -zv 192.243.3.2 7777
```
Capture wireshare.  
<img width="941" height="465" alt="image" src="https://github.com/user-attachments/assets/f0ef842a-c125-4503-8015-b15ef56391dc" />

Pada port `22` dan `80`, Knights merespons paket `SYN` dari Alice dengan `SYN-ACK`, yang menunjukkan bahwa terdapat layanan yang listening pada kedua port tersebut. Sementara itu, pada port `7777`, Knights merespons `SYN` dengan `RST-ACK` karena tidak terdapat layanan yang berjalan pada port tersebut. Dengan demikian, perbedaan TCP Flag dapat digunakan untuk membedakan port yang terbuka dan tertutup.  

### Soal 13 -   
- Knights → buat user `mika_admin`, pasang public key, matikan password login.
- Mika → generate SSH key, lalu gunakan private key untuk login.

Di Knights, buat user `mika_admin`  
```
adduser -D mika_admin

mkdir -p /home/mika_admin/.ssh
chmod 700 /home/mika_admin/.ssh
```

Di Mika, buat ssh key  
```
mkdir -p /root/.ssh
ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519_mika_admin

cat /root/.ssh/id_ed25519_mika_admin.pub
```

<img width="482" height="36" alt="image" src="https://github.com/user-attachments/assets/2829ba08-8551-4819-9efc-8217f156d04a" />

Hasil `cat /root/.ssh/id_ed25519_mika_admin.pub`  
```ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8sp7nlUzGMxaZ9VYqHEBxfta9f9PZD+9esuLrjMcjW root@Mika```  
<img width="481" height="34" alt="image" src="https://github.com/user-attachments/assets/6a0f9e9e-5782-453d-93a3-b7c134090492" />

Di Knights  
```
nano /home/mika_admin/.ssh/authorized_keys
```
Lalu masukkan public keynya.  
Setelah itu permission dan ownership diatur:  
```
chmod 600 /home/mika_admin/.ssh/authorized_keys
chown -R mika_admin:mika_admin /home/mika_admin/.ssh
```
Pada Knights, file konfigurasi SSH diedit:  
```
nano /etc/ssh/sshd_config

AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no
PubkeyAuthentication yes
```
Cek konfigurasi:  
```
sshd -t
```  
Kemudian restart SSH:  
```
pkill sshd
/usr/sbin/sshd
```

Pada Mika, koneksi dilakukan menggunakan private key:  
```
ssh -i /root/.ssh/id_ed25519_mika_admin mika_admin@192.243.3.2
```

<img width="486" height="274" alt="image" src="https://github.com/user-attachments/assets/1677cbf8-9cb2-4dbe-bbb7-0d617a4547b0" />


Analisis Wireshark  

Untuk melihat komunikasi SSH digunakan filter:  
```
ip.addr == 192.243.3.2 && tcp.port == 22
```
<img width="959" height="562" alt="image" src="https://github.com/user-attachments/assets/2bcd438a-051a-4bc5-ae7c-97ac21d50120" />

Berdasarkan hasil capture, koneksi SSH dari Mika (`192.243.1.3`) menuju Knights (`192.243.3.2`) diawali dengan TCP three-way handshake berupa `SYN`, `SYN-ACK`, dan `ACK`. Selanjutnya terjadi pertukaran versi protokol SSH dan proses Key Exchange. Setelah proses pertukaran kunci selesai, komunikasi selanjutnya ditampilkan sebagai `Encrypted packet`, sehingga isi komunikasi tidak terlihat sebagai plaintext.  

### Soal 15 -  
Buka `wired_usb_hid.pcap` di Wireshark. Kemudian untuk mencari descriptor USB, bisa pakai filter `usb`.  Kemudian, lihat panel tengah/bawah yang namanya Packet Details. Cari bagian Device Descriptor.  

<img width="959" height="563" alt="Screenshot 2026-09-17 144303" src="https://github.com/user-attachments/assets/c654aff1-5654-410d-aa1a-01163c948daf" />

Kemudian untuk keystrok, ketik filter `usb.capdata || usbhid.data` pada Wireshark untuk menampilkan data HID  

<img width="682" height="486" alt="image" src="https://github.com/user-attachments/assets/9ce071fe-97eb-435b-add7-aadd953ced89" />
Ambil data HID, kemudian decode keycode untuk mengetahui karakter yang diketik oleh perangkat USB.  
  
Setelah mendapatkan informasi dari hasil analisis PCAP, dilakukan validasi menggunakan socket server yang disediakan.   

<img width="1060" height="510" alt="image" src="https://github.com/user-attachments/assets/62aef049-a017-4806-bb31-b6fc20ae9a6c" />

### Soal 19 -  
Buka file `soal19_wired_smtp_threat.pcapng`  

Di Wireshark, masukkan display filter `tcp.port == 25` dan cari email pemerasan Eiri  

<img width="866" height="484" alt="image" src="https://github.com/user-attachments/assets/06b9411f-4291-45ab-8cb5-68d515e9b1ea" />

Lihat TCP Stream untuk melihat isi percakapan SMTP lengkap  
<img width="741" height="768" alt="image" src="https://github.com/user-attachments/assets/52e00214-7309-4ffd-844d-91d10a50009a" />  
<img width="620" height="768" alt="image" src="https://github.com/user-attachments/assets/99a51313-a848-4cb6-9728-f74f6212c6a7" />

Lakukan validasi pada `nc 10.4.89.250 3406`  

<img width="961" height="582" alt="image" src="https://github.com/user-attachments/assets/35b9b51e-8af5-493d-a32e-6b0d83f331d1" />

