# Panduan Pengetesan: Multipath SPF & ECMP

Dokumen ini memuat langkah-langkah untuk menyiapkan *environment*, menjalankan *controller*, hingga memverifikasi apakah pembagian beban (*load balancing*) dengan skema modifikasi bobot (*weight*) berjalan dengan benar.

## 1. Persiapan Virtual Environment & Dependensi

Karena kamu sudah membuat *virtual environment* menggunakan `uv` (yaitu folder `.venv`), pastikan *environment* tersebut sudah aktif di terminal kamu (VSCode biasanya mendeteksi secara otomatis).

### Langkah Aktivasi (Jika Belum Aktif):
**Di Linux / Dev Container (Terminal VS Code):**
```bash
source .venv/bin/activate
```

### Instalasi Dependensi:
Karena kita menggunakan basis controller `osken`, jalankan perintah berikut untuk menginstal seluruh pustaka yang dibutuhkan (jika `uv` belum terinstal, jalankan `pip install uv` terlebih dahulu, atau gunakan `pip install osken eventlet`):
```bash
uv pip install osken eventlet
```

---

## 2. Menjalankan Controller

Kita tidak menjalankan `base_controller.py` secara langsung karena file tersebut adalah *abstract base class* (kerangka dasar). Kita akan langsung menjalankan file turunan yang sudah kita buat, yaitu `multipath_spf.py`.

Buka terminal VS Code (yang sudah ada di dalam Dev Container, pastikan venv aktif), dan jalankan dari direktori utama proyek:
```bash
python SPF/controllers/multipath_spf.py
```
> **Catatan**: Script ini otomatis memanggil `osken-manager` di balik layar dan langsung memuat modul pencarian topologi (`--observe-links`). Kamu akan melihat log controller menyala dan bersiap menerima koneksi dari switch.

---

## 3. Menjalankan Emulator Mininet

Karena kamu sudah menggunakan fitur **Dev Container** di VS Code, kamu sudah berada di dalam lingkungan Linux (Docker) secara otomatis. Tidak perlu lagi memanggil `docker compose` atau `docker exec` secara manual!

**Langkah 1: Buka Terminal Baru**
Buka tab terminal baru di VS Code (tekan tombol `+` pada panel terminal).

**Langkah 2: Jalankan Topologi Mininet**
Jalankan topologi `diamond` menggunakan *script* kustom dari proyek kita. Karena *controller* dan Mininet berjalan di container yang sama, cukup gunakan IP `127.0.0.1` (localhost):
```bash
sudo mn --custom /workspaces/learn_sdn/SPF/topologies/topo-diamond_lab.py --topo diamond --controller remote,ip=127.0.0.1,port=6653 --mac --switch ovsk,protocols=OpenFlow13
```
*(Catatan: Kamu juga bisa mencoba topologi lain dengan argumen `--custom /workspaces/learn_sdn/SPF/topologies/topo-partial_mesh_lab.py --topo partial_mesh`).*

Jika berhasil, Mininet akan memunculkan *prompt* CLI seperti ini:
```text
*** Starting CLI:
mininet>
```

---

## 4. Proses Verifikasi (Testing Load Balancing 70:30)

Setelah Mininet terhubung ke Controller OSKen, kita bisa mengetes apakah pengaturan **Group Table (ECMP)** dengan bobot `[7, 3]` tadi berfungsi dengan baik.

### A. Uji Ping Terlebih Dahulu
Di konsol Mininet, ketikkan:
```bash
mininet> pingall
```
Semua *host* harus bisa terhubung. Saat *ping* ini berjalan, controller kita (`multipath_spf.py`) akan mencari jalur dari *source* ke *destination*.
- Cek terminal tempat *controller* berjalan! 
- Kamu seharusnya melihat pesan log seperti ini:
  `[MP-COMPUTE] ... found 2 path(s)`
  `[MP-INSTALL] ... paths=2 group=1 weights=[7, 3]`

### B. Memverifikasi OpenFlow Group Entries
Untuk memastikan bahwa bobot 70:30 benar-benar disuntikkan ke dalam *switch*, cukup buka tab terminal VS Code yang baru (karena kamu sudah di dalam Dev Container), lalu jalankan perintah ini untuk melihat *Group Table* di *ingress switch* (misalnya `s1`):
```bash
mininet> dpctl dump-groups -O OpenFlow13
```
Atau jika tidak berada di dalam Mininet CLI, kamu bisa menggunakan perintah bash:
```bash
sudo ovs-ofctl -O OpenFlow13 dump-groups s1
```
Kamu akan melihat output `type=select`. Di bagian *buckets*, kamu harusnya melihat dua buah *bucket*, yang satu memiliki `weight:7` dan yang satu lagi `weight:3`.

### C. Uji Throughput (Opsional / Tugas Aero)
Untuk melihat secara riil pembagian trafik, kamu bisa menjalankan *iperf* secara paralel atau melihat grafik telemetri (jika rekanmu Aero sudah menyiapkannya):
```bash
mininet> h1 iperf -s &
mininet> h2 iperf -c h1 -P 10 -t 10
```
Jika kita mengatur `weight` ke 50:50 (`[5, 5]`), paket akan terbagi seimbang. Namun karena kita bereksperimen dengan `[7, 3]`, salah satu tautan (*link*) di tengah *diamond* akan memikul beban jauh lebih berat daripada *link* alternatifnya.

---
**Selesai!** Jika seluruh pengujian di atas sesuai, maka target pekerjaan ini sudah selesai dengan sempurna dan siap digunakan oleh anggota tim lainnya.
