# Jarkom-Modul-1-2026-K-64  
Mahrinza Redouane Zakariyah  5027251074  
Dian Hanna Simanjuntak       5027251116
  
## Reporting
  
### Daftar Isi
- [Soal 1](#soal-1---konfigurasi-topologi-dan-ip-address)
- [Soal 2](#soal-2---koneksi-lain-ke-public-internet)
- [Soal 3](#soal-3---routing-antarjaringan)
- [Soal 4](#soal-4---nat-dan-dns-resolver)
- [Soal 5](#soal-5---persistensi-konfigurasi)
- [Soal 7](#soal-7---konfigurasi-ftp-server-pada-chisa)
- [Soal 9](#soal-9---mika)
- [Soal 12](#soal-12---alice-ke-knights)
- [Soal 13](#soal-13---ssh)
- [Soal 15](#soal-15---analisis-usb-hid)
- [Soal 19](#soal-19---smtp-threat)

  
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
Pada Lain, interface eth0 dikonfigurasikan untuk mendapatkan alamat IP secara otomatis menggunakan DHCP  

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
Agar konfigurasi tetap diterapkan setelah node dijalankan kembali, dibuat script `/root/init.sh`. Script ini digunakan untuk menjalankan konfigurasi yang diperlukan secara otomatis saat node start.  

Pada Lain:  
```
nano /root/init.sh
```  
Isi:  
```
#!/bin/sh

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```  
Kemudian dibuat executable:  
```
chmod +x /root/init.sh
```
Untuk mengecek hasil konfigurasi dibuat `/root/cek_status.sh`  
```
nano /root/cek_status.sh
```  
Isi:  
```
#!/bin/bash

echo "Interface"
ip -br a

echo
echo "Nat Table"
iptables -t nat -L -v -n
```
  
Kemudian:  
```
chmod +x /root/cek_status.sh
```  

<img width="481" height="374" alt="image" src="https://github.com/user-attachments/assets/cd4ffa20-0678-4743-b036-f9950ae661b4" />  

## Soal 6 - Packet Sniffing Wireshark & Traffic Generator pada Node Mika

### a. Download script generator traffic melalui link yang diberikan pada soal.

<img width="686" height="524" alt="no6_1" src="https://github.com/user-attachments/assets/e02f76cf-7b32-4328-8dae-3ee8be63bc61" />

>ekstrak zip filenya

<img width="663" height="120" alt="no6_2" src="https://github.com/user-attachments/assets/f30c3a10-9869-493e-8fc8-9d4498fe486c" />

<br>

### b. Script

>Buka console pada node Mika, lalu buat file bash script yang bernama traffic_protocol7.sh, kemudian copy-paste semua isi dari script yang kita download tadi ke dalam script traffic_protocol7.sh
```bash
nano traffic_protocol7.sh
```

>Beri izin eksekusi pada script traffic_protocol7
```bash
chmod +x traffic_protocol7.sh
```

>lalu eksekusi
```bash
./traffic_protokol7.sh
```

### c. Wireshark
>lalu buka wireshark melalui interface yang terhubung pada node Mika -> 
>Mulai proses capture. ->
>Pada kolom Display Filter di bagian atas Wireshark, ketikkan filter:

```
dns || icmp
```

>**Hasil capture**

<img width="748" height="500" alt="no6" src="https://github.com/user-attachments/assets/5fa97b9c-676b-4ac4-a1dc-1f2483debcca" />

## d. analisis
Penerapan display filter dns || icmp pada Wireshark berhasil menyaring 14 paket utama di node Mika (192.243.1.3), yang mencakup komunikasi Echo Request/Reply ICMP ke 8.8.8.8 dan 1.1.1.1 serta kueri DNS untuk domain seperti its.ac.id, example.com, google.com, cloudflare.com, dan github.com. Terlihat jelas bahwa seluruh aktivitas uji konektivitas ICMP berjalan lancar dan permintaan resolusi nama domain berhasil direspons oleh resolver tujuan.




### Soal 7 - Konfigurasi FTP Server pada Chisa  
Membuat FTP server pada node Chisa menggunakan vsFTPd dengan direktori `/var/wired/data`, kemudian mengatur hak akses:  
- Alice → dapat membaca dan menulis file.  
- Mika → hanya dapat membaca file.  
- Eiri → tidak diperbolehkan mengakses FTP.  

Install vsFTPd pada node Chisa:  
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

## Soal 8 - FTP Client Upload & Analisis Sesi Wireshark pada Node Knights

### a. Persiapan Dokumen Laporan Intelijen

Pastikan file `knights_report.txt` sudah diunduh, diekstrak (jika berupa arsip), dan tersedia di dalam direktori kerja pada node Knights.

### b. Koneksi FTP dan Upload File

>Buka console pada node Knights, lalu lakukan koneksi FTP ke IP Server Chisa.
```bash
lftp 192.243.2.2
```
(username = alice, password = alice).

>Setelah berhasil login, pindah ke mode pasif (PASV) lalu unggah berkas `knights_report.txt` dan akhiri sesi FTP.
```bash
pasv
put knights_report.txt
quit
```

<img width="708" height="149" alt="no8" src="https://github.com/user-attachments/assets/25ecc38a-7307-402c-bbfb-b2ef5438cde8" />

### c. Capture
>Untuk step capture, pada saat itu kami tidak menggunakan wireshark dikarenakan ada kendala ketika ingin membuka wireshark. 
>jadi kami coba menggunakan script ini pada node chisa:
```
tcpdump -nn -i eth0 -A port 21
```

**Hasil capture**

<img width="1278" height="772" alt="no8_1" src="https://github.com/user-attachments/assets/c5feea71-bafc-4c71-81d4-df1d83c3c795" />

## d. Analisis

Berdasarkan hasil tangkapan Wireshark pada saat proses upload dokumen `knights_report.txt`, berikut adalah analisis rinci dari sesi FTP yang terjadi:

* **Perintah FTP untuk Upload (STOR)**: Klien mengirimkan perintah `STOR knights_report.txt`. Perintah ini menginstruksikan FTP server (Chisa) untuk menyimpan file yang diunggah tersebut ke dalam direktori tujuan (dalam hal ini `/var/wired/data`).
* **Kode Status Sukses Server (226)**: Setelah transfer data selesai, FTP server mengirimkan respons `226 Transfer complete`. Ini merupakan sinyal konfirmasi bahwa seluruh isi file telah diterima sepenuhnya tanpa kendala melalui jalur TCP Data Connection.
* **Port Data TCP pada Mode PASV**: Saat klien mengirimkan perintah `PASV` untuk menginisiasi mode pasif, server membalas dengan status `227 Entering Passive Mode (192,243,2,2,p1,p2)`. Port data TCP yang dinegosiasikan dapat dihitung menggunakan rumus berikut:

$$\text{Port Data TCP} = (p1 \times 256) + p2$$

Sebagai contoh perhitungan, apabila respons server di Wireshark menunjukkan `227 Entering Passive Mode (192,243,2,2,180,12)`, maka port data TCP yang digunakan adalah:

$$\text{Port Data} = (180 \times 256) + 12 = 46092$$

(Catatan: Pastikan untuk menyesuaikan nilai $p1$ dan $p2$ pada perhitungan di atas sesuai dengan angka riil yang tertera pada hasil capture Wireshark milikmu).

* **Aspek Keamanan (Plaintext Transmission)**: Karena protokol FTP standar tidak menerapkan enkripsi, seluruh perintah kontrol (`USER`, `PASS`, `STOR`) maupun isi data pada `knights_report.txt` dikirimkan dalam bentuk plaintext. Hal ini menunjukkan bahwa kredensial login dan isi dokumen intelijen berpotensi disadap oleh pihak ketiga yang melakukan *packet sniffing* pada jalur komunikasi yang sama.


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

## Soal 10 - Uji Ketahanan Koneksi & Analisis ICMP pada Node Knights

### a. Eksekusi Uji Ketahanan Koneksi (Ping)

>Buka terminal pada node Knights untuk melancarkan uji ketahanan jaringan menuju server Chisa. Sesuai dengan instruksi, jalankan perintah `ping` ke IP Chisa (`192.243.2.2`) menggunakan payload sebesar 128 bytes (`-s 128`), interval 0.3 detik (`-i 0.3`), dengan total 77 paket (`-c 77`).
```bash
ping -c 77 -s 128 -i 0.3 192.243.2.2
```

**Hasil Eksekusi Terminal**

<img width="1170" height="584" alt="no10" src="https://github.com/user-attachments/assets/80a6a8bf-fe90-494d-bd7e-27082e52d78a" />

### b. Capture Paket ICMP via Wireshark

>Buka Wireshark dan mulai proses capture pada interface jaringan yang terhubung ke node Knights. Gunakan display filter `icmp` pada kolom pencarian Wireshark untuk menyaring dan memfokuskan pantauan khusus pada lalu lintas pengujian ping tersebut.


**Hasil Capture Wireshark**

<img width="1249" height="442" alt="no10_1" src="https://github.com/user-attachments/assets/bd7e5fea-9a74-43fe-9430-a51d1e0a8857" />

### c. Pembahasan & Analisis Soal 10

Berdasarkan pengujian di terminal dan tangkapan paket melalui Wireshark, berikut adalah analisis mendalam mengenai sesi uji ketahanan koneksi tersebut:

**1. Nilai ICMP Type dan Code**

Dari hasil analisis paket ICMP yang tertangkap di Wireshark, kita dapat melihat struktur dari protokol pesan kontrol tersebut:

* **Echo (ping) Request**: Paket yang dikirimkan dari Knights menuju Chisa sebagai bentuk pengujian teridentifikasi menggunakan parameter `Type: 8` dan `Code: 0`.
* **Echo (ping) Reply**: Paket balasan yang dikembalikan oleh Chisa menuju Knights teridentifikasi menggunakan parameter `Type: 0` dan `Code: 0`.

**2. Analisis Packet Loss**

Setelah eksekusi 77 paket `ping` selesai, terminal akan menghasilkan ringkasan statistik jaringan.

* Keberhasilan transmisi dapat dilihat pada metrik packet loss (misalnya: `77 packets transmitted, 77 received, 0% packet loss`). Nilai 0% packet loss menunjukkan bahwa jalur komunikasi antara node Knights dan Chisa beroperasi dengan sangat stabil. Seluruh paket berhasil mencapai tujuan dan kembali tanpa ada satu pun data yang terbuang (drop) di tengah proses transmisi.

**3. Analisis RTT (Round Trip Time)**

Kualitas latensi jaringan dapat dievaluasi lebih lanjut melalui indikator RTT yang mencakup nilai min/avg/max:

* **min**: Mengindikasikan waktu tempuh balasan tercepat (minimum) selama pengujian berlangsung.
* **avg**: Menggambarkan rata-rata waktu tempuh dari keseluruhan 77 paket uji (average).
* **max**: Menunjukkan waktu tempuh terlama dari suatu paket (maximum).
* **Kesimpulan RTT**: Apabila rentang selisih antara nilai min dan max tergolong kecil dan mendekati nilai rata-rata (avg), hal ini membuktikan bahwa latensi di dalam jaringan bersifat konsisten. Jaringan terbebas dari lonjakan keterlambatan yang ekstrem (*jitter* atau *lag*).

## Soal 11 - Bukti Kelemahan Protokol Telnet (Node Chisa & Eiri)

### a. Persiapan Layanan Telnet di Node Server (Chisa)

>Buka console pada node Chisa. Pertama, instal paket yang menyediakan layanan telnet daemon (`telnetd`), yaitu `busybox-extras`.
```bash
apk update && apk add busybox-extras
```

>Selanjutnya, buat akun baru bernama `phantom_user` dan atur password-nya menjadi `wired_ghost`, lalu jalankan layanan `telnetd`.
```bash
adduser phantom_user
# (Masukkan password: wired_ghost saat diminta, abaikan peringatan bad password, lalu ketik ulang password)
telnetd
```

**Hasil eksekusi instalasi paket:**

<img width="645" height="222" alt="no11_install" src="https://github.com/user-attachments/assets/08c09b2e-c3f1-4d71-98cb-9738bef3a140" />

**Hasil eksekusi pembuatan user dan menjalankan telnetd:**

<img width="662" height="207" alt="no11_1" src="https://github.com/user-attachments/assets/4c0b1412-0aac-46a4-becd-bb7395fdd534" />

### b. Login Telnet dari Node Client (Eiri)

>Buka console pada node Eiri, lalu lakukan koneksi Telnet ke IP server Chisa (`192.243.2.2`).
```bash
telnet 192.243.2.2
```

>Saat prompt login muncul, masukkan kredensial yang telah dibuat sebelumnya:
> - Chisa login: `phantom_user`
> - Password: `wired_ghost`

**Hasil login Telnet berhasil:**

<img width="807" height="491" alt="no11_2" src="https://github.com/user-attachments/assets/e7d1a7bb-dd7c-4519-a3b4-352e358b1b4d" />

<img width="647" height="305" alt="no11_3" src="https://github.com/user-attachments/assets/84017e44-2fee-412c-b83f-ff98f349ff5a" />

### c. Analisis Sesi Menggunakan Wireshark

>Buka Wireshark pada interface yang menghubungkan Eiri dan Chisa selama proses login berlangsung. Pada kolom Display Filter, ketikkan filter `telnet` atau klik kanan pada salah satu paket TCP/TELNET lalu pilih Follow > TCP Stream untuk menyatukan percakapan.

**Tangkapan Paket (Packet List):** Terlihat lalu lintas Telnet di mana data dikirim per 1 byte.

<img width="1245" height="780" alt="no11_TELNET_1" src="https://github.com/user-attachments/assets/03909523-74b0-445b-b22f-b41d547be221" />

**Hasil Follow TCP Stream:**

<img width="829" height="795" alt="no11_TELNET_2" src="https://github.com/user-attachments/assets/0d0292dd-9e17-41b4-bf81-e08211736bde" />

### d. Pembahasan & Analisis Soal 11

Berdasarkan pengujian dan tangkapan Wireshark di atas, terdapat dua poin kelemahan utama dan karakteristik dari protokol Telnet yang berhasil dibuktikan:

**1. Kredensial Terekspos dalam Plain Text**

Dari fitur Follow TCP Stream di Wireshark, kita dapat melihat seluruh komunikasi antara Eiri (klien, warna merah) dan Chisa (server, warna biru) secara gamblang. Kredensial username (`phantom_user`) dan password (`wired_ghost`) terlihat dengan sangat jelas dalam bentuk teks terang (plain text). Hal ini membuktikan bahwa Telnet tidak memiliki mekanisme enkripsi sama sekali, sehingga sangat rentan terhadap serangan penyadapan (*sniffing*). Siapa pun yang berada di dalam jaringan tersebut dapat dengan mudah mencuri kredensial login.

**2. Pengiriman Karakter dalam Paket TCP Terpisah (1-byte payload)**

Pada daftar paket Wireshark (gambar Packet List), terlihat banyak sekali paket yang dikirimkan dengan Length Info sebesar "1 byte data". Hal ini terjadi karena Telnet menggunakan mekanisme *Character Mode* (Echo Mode). Saat mode ini aktif, setiap kali pengguna mengetikkan satu karakter (satu ketukan keyboard), karakter tersebut akan langsung dibungkus dalam satu paket TCP terpisah dan dikirim ke server. Server kemudian memproses karakter itu dan mengirimkannya kembali (*echo*) ke klien agar muncul di layar terminal pengguna. Meskipun mekanisme ini memungkinkan interaksi *real-time* dengan terminal jarak jauh, hal ini sangat tidak efisien karena menghasilkan *overhead* jaringan yang besar (membutuhkan header TCP/IP penuh hanya untuk mengirim 1 byte data per ketukan jari).


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

### Soal 13 - SSH  
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
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8sp7nlUzGMxaZ9VYqHEBxfta9f9PZD+9esuLrjMcjW root@Mika
```

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


Analisis Wireshark, untuk melihat komunikasi SSH digunakan filter:  
```
ip.addr == 192.243.3.2 && tcp.port == 22
```

<img width="959" height="562" alt="image" src="https://github.com/user-attachments/assets/2bcd438a-051a-4bc5-ae7c-97ac21d50120" />  
  
Berdasarkan hasil capture, koneksi SSH dari Mika (`192.243.1.3`) menuju Knights (`192.243.3.2`) diawali dengan TCP three-way handshake berupa `SYN`, `SYN-ACK`, dan `ACK`. Selanjutnya terjadi pertukaran versi protokol SSH dan proses Key Exchange. Setelah proses pertukaran kunci selesai, komunikasi selanjutnya ditampilkan sebagai `Encrypted packet`, sehingga isi komunikasi tidak terlihat sebagai plaintext.  

## 14. Analisis Serangan Brute-Force (Wired Protocol 7)

>Setelah gagal mengakses FTP, Eiri melancarkan serangan brute-force terhadap form login web Alice. Analisis file capture `wired_bruteforce.pcapng` untuk mengidentifikasi alamat IP penyerang, target IP beserta port yang diserang, password user `lain_admin` yang berhasil ditembus, serta web server software dan versi yang dilaporkan pada response header. Validasi temuan kalian pada socket server: `nc [IP_Group] 3401`

### a. Identifikasi IP dan Port Target

>Buka file capture `soal14_wired_bruteforce.pcapng` di Wireshark. Masukkan filter `http.request.method == "POST"` untuk menyaring percobaan login.

Dari hasil filter, terlihat IP penyerang (`Source`) adalah `172.26.7.50` dan IP target (`Destination`) adalah `172.26.7.100`, dengan puluhan paket POST berulang ke `/login.php` yang menandakan percobaan login secara otomatis (brute-force).

<img width="1248" height="617" alt="no14_wireshark_1" src="https://github.com/user-attachments/assets/c323800a-6764-4bab-8d66-e51949bdf858" />

### b. Identifikasi Kredensial dan Versi Web Server

>Ubah filter Wireshark menjadi `http.response.code == 200 || http.response.code == 302` untuk melihat respons login yang berhasil.

<img width="1256" height="237" alt="no14_wireshark_2" src="https://github.com/user-attachments/assets/2795c53d-3380-4315-a35c-b565ad73dd4e" />

>Klik kanan pada paket yang muncul (stream 59, menuju `172.26.7.100:8080`), lalu pilih **Follow > HTTP Stream**.

<img width="834" height="792" alt="no14_wireshark_3" src="https://github.com/user-attachments/assets/7e8278b5-6d40-478a-9d9a-45be7feb5931" />

Dari hasil *Follow HTTP Stream*, didapatkan detail sebagai berikut:

* **Port target**: `8080` (terlihat dari header `Host: 172.26.7.100:8080`)
* **Kredensial berhasil**: `username=lain_admin&password=wired_pr0tocol_7`
* **Response server**: `HTTP/1.1 200 OK` dengan body `Success! Login successful.`
* **Web Server & Versi**: `Server: Apache/2.4.62` 

### c. Validasi Temuan pada Socket Server

>Buka terminal dan lakukan koneksi ke socket server menggunakan netcat untuk melakukan validasi jawaban.
```bash
nc 10.4.89.250 3401
```

>Masukkan data hasil analisis secara berurutan sesuai yang diminta oleh server:
> - IP Attacker: `172.26.7.50`
> - Target IP:Port: `172.26.7.100:8080`
> - Password: `wired_pr0tocol_7`
> - Web Server: `Apache/2.4.62`


<img width="892" height="364" alt="no14_2" src="https://github.com/user-attachments/assets/712d646e-26e0-4bcd-9f59-9a7c59e322bd" />


**Flag:** `KOMJAR26{W1r3d_Brut3_ofGWOszZFdRWl2gbaXEJsvORj}`


### Soal 15 - Analisis USB HID  
Buka `wired_usb_hid.pcap` di Wireshark. Kemudian untuk mencari descriptor USB, bisa pakai filter `usb`.  Kemudian, lihat panel tengah/bawah yang namanya Packet Details. Cari bagian Device Descriptor.  

<img width="959" height="563" alt="Screenshot 2026-09-17 144303" src="https://github.com/user-attachments/assets/c654aff1-5654-410d-aa1a-01163c948daf" />

Kemudian untuk keystrok, ketik filter `usb.capdata || usbhid.data` pada Wireshark untuk menampilkan data HID  

<img width="682" height="486" alt="image" src="https://github.com/user-attachments/assets/9ce071fe-97eb-435b-add7-aadd953ced89" />  
  
Ambil data HID, kemudian decode keycode untuk mengetahui karakter yang diketik oleh perangkat USB.  
  
Setelah mendapatkan informasi dari hasil analisis PCAP, dilakukan validasi menggunakan socket server yang disediakan.   

<img width="1060" height="510" alt="image" src="https://github.com/user-attachments/assets/62aef049-a017-4806-bb31-b6fc20ae9a6c" />

## 16. Analisis Pencurian Kredensial dan Unduhan Malware FTP

### a. Analisis Lalu Lintas FTP pada Wireshark

>Buka file capture `soal16_wired_ftp_theft.pcapng` di Wireshark. Masukkan filter `ftp` untuk menyaring seluruh lalu lintas protokol FTP.

Dari lalu lintas paket yang ada, terlihat tiga sesi FTP berbeda (ke `10.7.3.60`, `10.7.3.30`, dan `198.51.100.7`). Dengan menyaring lebih lanjut menggunakan filter `ftp.request.command == "RETR" || ftp-data`, ditemukan tiga permintaan unduh file, di antaranya perintah `RETR knights_payload.exe` menuju IP `198.51.100.7` — inilah interaksi unduhan malware yang dimaksud, sehingga IP server FTP penyedia malware terdeteksi di `198.51.100.7`.

<img width="1248" height="795" alt="no16_2" src="https://github.com/user-attachments/assets/f2c4bcff-54f7-4505-9494-25062c9510ab" />

<img width="1251" height="801" alt="no16_3" src="https://github.com/user-attachments/assets/11029edd-aa49-486f-a8ee-a205602415bc" />

### b. Identifikasi Banner, Kredensial, dan Ukuran File

>Klik kanan pada paket interaksi FTP tersebut, lalu pilih **Follow > TCP Stream**.

<img width="827" height="790" alt="no16_4" src="https://github.com/user-attachments/assets/56ce30ca-4c94-4224-8d82-ca7620903d0e" />


Berdasarkan pesan respons dan perintah pada stream FTP di atas:

* **Banner Server**: `vsftpd 3.0.5` (terlihat pada sambungan awal `220 Welcome to Wired FTP Server (vsftpd 3.0.5)`).
* **Kredensial Login**: `knights_agent:N4v1_s3cur3_2026` (dari perintah `USER knights_agent` dan `PASS N4v1_s3cur3_2026`).
* **Ukuran File Malware**: `524288` bytes (terlihat pada balasan `213 524288` atas perintah `SIZE knights_payload.exe`, serta dikonfirmasi ulang pada pesan `150 Opening BINARY mode data connection for knights_payload.exe (524288 bytes)`).

### c. Validasi Temuan pada Socket Server

>Hubungkan ke socket server menggunakan netcat untuk memasukkan data hasil analisis.
```bash
nc 10.4.89.250 3403
```

>Masukkan jawaban secara berurutan sesuai format yang diminta:
> - FTP Server IP: `198.51.100.7`
> - FTP Server Software Banner: `vsftpd 3.0.5`
> - Credentials (user:pass): `knights_agent:N4v1_s3cur3_2026`
> - Malware File Size (bytes): `524288`

<img width="892" height="374" alt="no16_5" src="https://github.com/user-attachments/assets/2728bae2-7f01-4bda-be2f-8a1520bddbd2" />

**Flag:** `KOMJAR26{FTP_Th3ft_R2ezQCoEsXG66qwXkkMeQTanq}`

## 17. Analisis Unduhan Malware melalui Protokol HTTP (HTTP C2)

### a. Analisis Query DNS dan Resolusi Domain

>Buka file capture `soal17_wired_http_c2.pcapng` di Wireshark. Perhatikan pencarian DNS pada paket 25 dan 26 untuk menemukan domain yang diakses sebelum pengunduhan payload.

=<img width="1254" height="793" alt="no17_1" src="https://github.com/user-attachments/assets/2cb52654-36aa-4015-b10c-45d2c9d38e6f" />

* Klien (`10.7.1.50`) melakukan DNS query untuk domain `wired-update.net` pada paket 25.
* DNS Server (`8.8.8.8`) mengembalikan balasan pada paket 26 bahwa `wired-update.net` berada pada alamat IP `203.0.113.42`.

(Catatan: sebelumnya terdapat query DNS lain seperti `cdnstore.io` dan `trackerx.io` pada lalu lintas capture, namun keduanya bukan domain yang relevan dengan pengunduhan malware — `trackerx.io` bahkan tidak ditemukan/`No such name`).

### b. Analisis Permintaan dan Respons HTTP

>Periksa paket 30 dan 31 yang berisi lalu lintas HTTP pengunduhan berkas malware.

<img width="1254" height="799" alt="no17_2" src="https://github.com/user-attachments/assets/0e2fc43a-f3e9-4b7d-a5e0-24512b9914ed" />

* **Paket 30 (HTTP GET Request)**: Klien mengirimkan permintaan `GET /navi_agent.exe HTTP/1.1` ke IP `203.0.113.42` dengan header `Host: wired-update.net`.

<img width="1252" height="795" alt="no17_3" src="https://github.com/user-attachments/assets/128f7d85-f986-41c3-acac-af373bd08cc1" />

* **Paket 31 (HTTP Response)**: Server web memberikan respons `HTTP/1.1 200 OK` dengan header `Server: nginx/1.24.0` dan `Content-Type: application/octet-stream`, yang menandakan payload biner (`navi_agent.exe`) berhasil diunduh sepenuhnya.

<img width="1252" height="794" alt="no17_4" src="https://github.com/user-attachments/assets/d532254f-bdc0-4e7e-8ea1-bdbc5d06ecd6" />

### c. Validasi Temuan pada Socket Server

>Hubungkan ke socket server menggunakan netcat pada port `3404` untuk memvalidasi seluruh parameter temuan.
```bash
nc 10.4.89.250 3404
```

>Masukkan data sesuai pertanyaan yang diajukan sistem:
> - Domain Name (Host): `wired-update.net`
> - Web Server IP Address: `203.0.113.42`
> - Malware Executable Filename: `navi_agent.exe`
> - HTTP Status Response Code: `200`

<img width="1170" height="619" alt="no17_5" src="https://github.com/user-attachments/assets/1f6f5816-dd39-4f16-912a-f388852b13b6" />

**Flag:** `KOMJAR26{Navi_C2_D0wnl04d_uApWZjAmB2PSUAqwE8pqLXHom}`

## 18. Analisis Transfer Malware Lateral via Protokol SMB

### a. Identifikasi Protokol dan Alamat IP

>Langkah pertama adalah membuka file capture `wired_smb_transfer.pcapng` di Wireshark. Dari lalu lintas yang terekam, kita dapat melihat bahwa komunikasi jaringan didominasi oleh protokol file sharing Windows.

<img width="1245" height="797" alt="no18" src="https://github.com/user-attachments/assets/35b9a662-239d-4301-9a43-62028602cf78" />

* **Protokol Jaringan**: Protokol yang dieksploitasi untuk mentransfer file ini adalah SMB (diidentifikasi sebagai SMB2 pada Wireshark, terlihat sejak paket *Negotiate Protocol Request*).
* **IP Pengirim (Attacker)**: Alamat IP host sumber yang mengirimkan instruksi dan malware adalah `10.7.3.100`.
* **IP Penerima (Victim)**: Alamat IP host korban yang menerima malware adalah `10.7.1.50`.

<img width="1245" height="797" alt="no18_1" src="https://github.com/user-attachments/assets/bd9f63b5-0c04-4ed9-bac8-a94cffb2d262" />

### b. Identifikasi Folder Tujuan dan Nama File Malware

>Selanjutnya, kita menelusuri paket-paket spesifik dalam stream tersebut untuk mengetahui ke mana file disimpan dan apa namanya.

<img width="1245" height="797" alt="no18_3" src="https://github.com/user-attachments/assets/c25b442b-df58-4760-9a01-262858e92406" />

* **Folder Tujuan**: Pada paket nomor 12 (*Tree Connect Request*), terlihat bahwa penyerang mengakses *administrative share* pada sistem korban dengan rujukan path `\\10.7.1.50\ADMIN$`. Ini berarti folder tujuan penyimpanannya adalah `ADMIN$`.

<img width="1245" height="797" alt="no18_4" src="https://github.com/user-attachments/assets/05a35c2e-a772-40ea-a3a4-66d5a0fe1dca" />

* **Nama File Executable**: Pada paket nomor 16 (*Create Request*), terdapat permintaan pembuatan file baru. Nama file *executable* malware yang ditransfer masuk ke dalam direktori `System32` korban adalah `wired_trojan_payload.exe`.

### c. Validasi Temuan pada Socket Server

>Terakhir, hubungkan ke socket server menggunakan netcat pada port `3405` untuk mengonfirmasi hasil analisis.
```bash
nc 10.4.89.250 3405
```

>Masukkan data temuan secara berurutan sesuai pertanyaan sistem:
> - Network file sharing protocol: `SMB`
> - Source host IP: `10.7.3.100`
> - Victim host IP: `10.7.1.50` (Pastikan mengisi `10.7.1.50`, bukan IP yang salah ketik seperti percobaan pertama di terminal).
> - Target share or directory: `ADMIN$`
> - Filename of the executable malware: `wired_trojan_payload.exe`

<img width="1167" height="619" alt="no18_5" src="https://github.com/user-attachments/assets/41c2f761-ba9c-43ba-9b56-dfa9df4c2e5d" />

**Flag:** `KOMJAR26{SMB_Tr4nsf3r_Tssoap3oiw7cUlI0Eq7fldJSv}`


### Soal 19 - SMTP Threat  
Buka file `soal19_wired_smtp_threat.pcapng`  

Di Wireshark, masukkan display filter `tcp.port == 25` dan cari email pemerasan Eiri  

<img width="866" height="484" alt="image" src="https://github.com/user-attachments/assets/06b9411f-4291-45ab-8cb5-68d515e9b1ea" />

Lihat TCP Stream untuk melihat isi percakapan SMTP lengkap  

<img width="741" height="768" alt="image" src="https://github.com/user-attachments/assets/52e00214-7309-4ffd-844d-91d10a50009a" />  
<img width="620" height="768" alt="image" src="https://github.com/user-attachments/assets/99a51313-a848-4cb6-9728-f74f6212c6a7" />

Lakukan validasi pada `nc 10.4.89.250 3406`  

<img width="961" height="582" alt="image" src="https://github.com/user-attachments/assets/35b9b51e-8af5-493d-a32e-6b0d83f331d1" />

## 20. Analisis Dekripsi Lalu Lintas TLS (TLS Decrypted Stream)

### a. Konfigurasi Keylog di Wireshark

>Mengingat komunikasi malware disembunyikan di balik saluran terenkripsi, langkah pertama yang harus dilakukan adalah mendekripsi lalu lintas tersebut menggunakan file keylog yang telah disediakan (`keyslogfile.txt`).

>- Pada Wireshark, navigasikan ke **Edit > Preferences**.
>- Pilih menu **Protocols**, lalu cari dan pilih **TLS**.
>- Pada kolom **(Pre)-Master-Secret log filename**, klik **Browse** dan masukkan file `keyslogfile.txt`. Setelah diaplikasikan, Wireshark akan otomatis mendekripsi paket TLS yang memiliki kunci yang bersesuaian.

<img width="814" height="574" alt="no20_2" src="https://github.com/user-attachments/assets/1b0519b0-59f0-4b22-aafa-023a36238ebf" />

### b. Identifikasi Parameter TLS dan HTTP

>Setelah dekripsi berhasil, kita dapat melakukan **Follow TLS Stream** (atau HTTP Stream) untuk menganalisis isi komunikasi secara plaintext.

* **Versi Protokol TLS**: Pada daftar paket (kolom Protocol), terlihat bahwa komunikasi terenkripsi dinegosiasikan menggunakan versi `TLSv1.2`.

<img width="1825" height="802" alt="no20_3" src="https://github.com/user-attachments/assets/11073d3c-45da-420d-9e0a-c8528ca6c46c" />

* **Domain Name (SNI)**: Dari paket *Client Hello*, klien meminta akses ke host dengan *Server Name Indication* (SNI) `example.com`.

<img width="1825" height="802" alt="no20_4" src="https://github.com/user-attachments/assets/b393148c-78ed-49e8-8bc5-b302f7b8f719" />

* **IP Server HTTPS**: Alamat IP tujuan (*Destination*) dari server HTTPS tersebut adalah `93.184.216.34`.

<img width="1825" height="802" alt="no20_5" src="https://github.com/user-attachments/assets/d00b91e7-1362-40d1-88d0-5dceca138eb3" />

Selanjutnya, dari dalam sesi HTTP yang kini sudah bisa dibaca (didekripsi), kita bisa melihat header request yang dikirim oleh klien:

* **User-Agent**: Klien menggunakan *command-line tool* untuk melakukan request, yang diidentifikasi dari string `curl/7.62.0`.

<img width="1825" height="802" alt="no20_6" src="https://github.com/user-attachments/assets/0ca6b987-5988-48cb-9692-3d979ff73d99" />

* **HTTP Request Method & Path**: Baris pertama dari HTTP request menunjukkan metode dan path yang digunakan, yaitu `HEAD / HTTP/1.1`.

<img width="1825" height="802" alt="no20_7" src="https://github.com/user-attachments/assets/acc579d4-bb6a-498f-bbcd-bcca6912bea9" />

### c. Validasi Temuan pada Socket Server

>Langkah terakhir adalah memvalidasi seluruh temuan ke socket server menggunakan netcat pada port `3407`.
```bash
nc 10.4.89.250 3407
```

>Masukkan jawaban secara berurutan saat diinstruksikan oleh server:
> - Specific TLS protocol version: `TLSv1.2`
> - Domain name (SNI / Host): `example.com`
> - IP address of the HTTPS server: `93.184.216.34`
> - User-Agent string: `curl/7.62.0`
> - HTTP request method and path: `HEAD / HTTP/1.1`

<img width="804" height="405" alt="no20_8" src="https://github.com/user-attachments/assets/6e144e58-9e77-4b1b-9262-af76a1e941f4" />

**Flag:** `KOMJAR26{TLS_D3crypt_cTtcuYV9AqEArZEauyuYNJzim}`
