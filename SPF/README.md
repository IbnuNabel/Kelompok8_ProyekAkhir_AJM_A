# Proyek Akhir Arsitektur Jaringan Modern: Implementasi & Analisis Multipath SPF

Proyek ini bertujuan untuk mengevaluasi performa algoritme **Multipath SPF** dibandingkan dengan algoritme **Single-path** (Dijkstra & Bellman-Ford) pada lingkungan SDN menggunakan **OSKen** dan **Mininet**.

## 👥 Anggota Kelompok
* **Ibnu Nabel Fauzi** - PM & Data Analyst
* **Amos Juang** - Network Designer
* **Sandhika Rizqi Ramadhan** - Multipath Developer
* **Aldersyifan Arzada Ahmad** - Single-path Developer
* **Aero Nathanael Silalahi** - QA & Test Engineer

## 🚀 Desain Eksperimen
Eksperimen dilakukan pada dua jenis topologi untuk melihat pengaruh struktur jaringan terhadap performa:
1. **Topologi Diamond**: Baseline dengan 2 jalur alternatif yang setara.
2. **Topologi Partial Mesh**: Skenario kompleks dengan >2 jalur alternatif.

## 🛠️ Cara Menjalankan Eksperimen

### 1. Prasyarat
Pastikan sistem Anda telah terinstal:
* Python 3 
* Mininet
* OSKen Controller 

### 2. Menjalankan Controller
Buka terminal baru dan jalankan controller yang diinginkan (contoh Multipath):
```bash
osken-manager controllers/multipath_spf.py
```

### 3. Menjalankan Topologi
Buka terminal lain dan jalankan skrip topologi:
* Untuk Topologi Diamond:
```bash
sudo python3 topologies/topo-diamond_lab.py
```
* Untuk Topologi Partial Mesh:
```bash
sudo python3 topologies/topo-partial_mesh_lab.py
```

### 4. Pengukuran Data
Gunakan iperf atau ping untuk mengumpulkan metrik throughput dan latensi. Metrik evaluasi utama mencakup:  
* Throughput Agregat: Kapasitas total pengiriman data.
* Latensi: End-to-End Delay.
* Keseimbangan Beban: Distribusi trafik pada jalur alternatif.

## 📚 Referensi
Repositori Dasar: github.com/abazh/learn_sdn.
