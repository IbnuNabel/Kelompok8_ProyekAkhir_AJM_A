# Panduan Pengetesan: Multipath SPF & ECMP

Dokumen ini memuat langkah-langkah untuk menyiapkan *environment*, menjalankan *controller*, hingga memverifikasi apakah pembagian beban (*load balancing*) dengan skema modifikasi bobot (*weight*) berjalan dengan benar.

## 1. Persiapan Virtual Environment & Dependensi

Karena kamu sudah membuat *virtual environment* menggunakan `uv` (yaitu folder `.venv`), pastikan *environment* tersebut sudah aktif di terminal kamu (VSCode biasanya mendeteksi secara otomatis).

### Langkah Aktivasi (Jika Belum Aktif):
**Di Windows (Command Prompt / PowerShell):**
```bash
.venv\Scripts\activate
```

### Instalasi Dependensi:
Karena kita menggunakan basis controller `osken`, jalankan perintah berikut untuk menginstal seluruh pustaka yang dibutuhkan:
```bash
uv pip install osken eventlet
```

---

## 2. Menjalankan Controller

Kita tidak menjalankan `base_controller.py` secara langsung karena file tersebut adalah *abstract base class* (kerangka dasar). Kita akan langsung menjalankan file turunan yang sudah kita buat, yaitu `multipath_spf.py`.

Buka terminal (pastikan venv masih aktif), dan jalankan:
```bash
python controllers/multipath_spf.py
```
> **Catatan**: Script ini otomatis memanggil `osken-manager` di balik layar dan langsung memuat modul pencarian topologi (`--observe-links`). Kamu akan melihat log controller menyala dan bersiap menerima koneksi dari switch.

---

## 3. Menjalankan Emulator Mininet (via Docker)

Kita menggunakan Docker untuk menjalankan Mininet agar *environment* lebih stabil dan konsisten.

**Langkah 1: Jalankan Container Mininet**
Buka terminal baru di direktori proyek ini (pastikan Docker Desktop sudah menyala), lalu jalankan:
```bash
docker compose up -d
```

**Langkah 2: Masuk ke Shell Mininet**
Setelah *container* berjalan, masuk ke dalam terminal *container* tersebut dengan perintah:
```bash
docker exec -it mininet-emulator bash
```

**Langkah 3: Jalankan Topologi Mininet**
Setelah masuk ke *shell* container, jalankan topologi `diamond` (direktori `/topologies` sudah ter-mount otomatis dari Windows). Pastikan menggunakan IP `host.docker.internal` agar terhubung ke controller di Windows:
```bash
mn --custom /topologies/topo-diamond_lab.py --topo diamond --controller remote,ip=host.docker.internal,port=6653 --mac --switch ovsk,protocols=OpenFlow13
```
*(Catatan: Kamu juga bisa mencoba topologi lain dengan argumen `--custom /topologies/topo-partial_mesh_lab.py --topo partial_mesh`).*

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
Untuk memastikan bahwa bobot 70:30 benar-benar disuntikkan ke dalam *switch*, jalankan perintah ini di dalam container Mininet (buka terminal baru dan jalankan `docker exec -it mininet-emulator bash` jika kamu sedang berada di prompt `mininet>`), untuk melihat *Group Table* di *ingress switch* (misalnya `s1`):
```bash
dpctl dump-groups
```
Atau jika tidak ada `dpctl`, kamu bisa menggunakan:
```bash
ovs-ofctl -O OpenFlow13 dump-groups s1
```
Kamu akan melihat output `type=select`. Di bagian *buckets*, kamu harusnya melihat dua buah *bucket*, yang satu memiliki `weight=7` dan yang satu lagi `weight=3`.

### C. Uji Throughput (Opsional / Tugas Aero)
Untuk melihat secara riil pembagian trafik, kamu bisa menjalankan *iperf* secara paralel atau melihat grafik telemetri (jika rekanmu Aero sudah menyiapkannya):
```bash
mininet> h1 iperf -s &
mininet> h2 iperf -c h1 -P 10 -t 10
```
Jika kita mengatur `weight` ke 50:50 (`[5, 5]`), paket akan terbagi seimbang. Namun karena kita bereksperimen dengan `[7, 3]`, salah satu tautan (*link*) di tengah *diamond* akan memikul beban jauh lebih berat daripada *link* alternatifnya.

---
**Selesai!** Jika seluruh pengujian di atas sesuai, maka target pekerjaan ini sudah selesai dengan sempurna dan siap digunakan oleh anggota tim lainnya.
