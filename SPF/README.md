# Analisis Komparatif Algoritme Dijkstra, Bellman-Ford, dan Suurballe pada Arsitektur Multipath SPF Berbasis SDN

## Anggota Kelompok
* **Ibnu Nabel Fauzi**
* **Amos Juang** 
* **Sandhika Rizqi Ramadhan** 
* **Aldersyifan Arzada Ahmad**
* **Aero Nathanael Silalahi**

## Deskripsi Proyek

Repositori ini berisi implementasi, konfigurasi lingkungan eksperimen, serta evaluasi performa tiga algoritme perutean, yaitu **Dijkstra Multipath**, **Bellman-Ford Multipath**, dan **Suurballe Disjoint Paths**, pada arsitektur *Software-Defined Networking* (SDN).

Implementasi memanfaatkan *Control Plane* berbasis **OSKen Controller** dan *Data Plane* berbasis **Mininet Emulator** dengan dukungan protokol **OpenFlow 1.3**. Fokus penelitian adalah membandingkan karakteristik ketiga algoritme terhadap beberapa metrik kinerja jaringan, seperti waktu komputasi jalur, throughput, keseimbangan distribusi trafik (*load balancing*), dan ketahanan terhadap kegagalan jalur.

---

## Tujuan Penelitian

Penelitian ini bertujuan untuk:

1. Mengimplementasikan algoritme Dijkstra, Bellman-Ford, dan Suurballe pada lingkungan SDN.
2. Mengembangkan mekanisme multipath menggunakan fitur OpenFlow Group Table.
3. Mengevaluasi performa masing-masing algoritme pada berbagai skenario topologi jaringan.
4. Menganalisis efektivitas Equal-Cost Multipath (ECMP) dan jalur *edge-disjoint* dalam meningkatkan utilisasi jaringan.
5. Membandingkan karakteristik algoritme berdasarkan metrik throughput, latency, dan distribusi beban trafik.

---

## Arsitektur Sistem

Lingkungan eksperimen dibangun menggunakan pendekatan SDN yang memisahkan fungsi kontrol dan fungsi forwarding jaringan.

### Control Plane

Komponen kontrol dijalankan menggunakan OSKen Controller yang bertanggung jawab untuk:

* Menemukan topologi jaringan secara otomatis.
* Menghitung jalur komunikasi antar-host.
* Menginstal aturan forwarding OpenFlow.
* Mengelola OpenFlow Group Table untuk implementasi multipath.

### Data Plane

Komponen data plane diemulasikan menggunakan Mininet dengan Open vSwitch yang mendukung OpenFlow 1.3.

Setiap switch OpenFlow berfungsi sebagai perangkat forwarding yang menerima aturan dari controller secara dinamis.

---

## Struktur Repositori

```text
Kelompok8_ProyekAkhir_AJM_A/
├── .devcontainer/
│   └── ...
│
├── scripts/
│   └── ...
│
├── SPF/
│   ├── algorithms/
│   │   ├── __init__.py
│   │   ├── bellman_ford.py
│   │   ├── dijkstra.py
│   │   └── suurballe.py
│   │
│   ├── controllers/
│   │   ├── __init__.py
│   │   ├── multipath_spf.py
│   │   ├── shortest_path.py
│   │   └── test_group_mod.py
│   │
│   └── topologies/
│       ├── __init__.py
│       ├── topo-diamond_lab.py
│       └── topo-partial_mesh_lab.py
│
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
├── README.md
└── PANDUAN_PENGUJIAN_SUURBALLE.md
```

---

## Deskripsi Direktori

### SPF/algorithms/

Berisi implementasi algoritme pencarian jalur yang digunakan oleh controller.

| Berkas          | Fungsi                                                               |
| --------------- | -------------------------------------------------------------------- |
| dijkstra.py     | Implementasi algoritme Dijkstra                                      |
| bellman_ford.py | Implementasi algoritme Bellman-Ford                                  |
| suurballe.py    | Implementasi algoritme Suurballe untuk pencarian jalur edge-disjoint |

### SPF/controllers/

Berisi implementasi controller OpenFlow berbasis OSKen.

| Berkas            | Fungsi                                             |
| ----------------- | -------------------------------------------------- |
| multipath_spf.py  | Controller multipath berbasis OpenFlow Group Table |
| shortest_path.py  | Controller single-path sebagai baseline            |
| test_group_mod.py | Pengujian OpenFlow Group Modification              |

### SPF/topologies/

Berisi definisi topologi Mininet yang digunakan selama eksperimen.

| Berkas                   | Fungsi                                                 |
| ------------------------ | ------------------------------------------------------ |
| topo-diamond_lab.py      | Topologi Diamond dengan dua jalur ekuivalen            |
| topo-partial_mesh_lab.py | Topologi Partial Mesh dengan beberapa alternatif jalur |

---

## Spesifikasi Lingkungan Pengujian

Seluruh eksperimen dijalankan menggunakan lingkungan yang direproduksi melalui Docker dan Visual Studio Code Dev Container.

### Parameter Jaringan

| Parameter          | Nilai        |
| ------------------ | ------------ |
| Bandwidth Link     | 100 Mbps     |
| QoS Scheduler      | HFSC         |
| Delay Antar Switch | 2 ms         |
| Protokol SDN       | OpenFlow 1.3 |
| Controller         | OSKen        |
| Emulator           | Mininet      |
| Virtual Switch     | Open vSwitch |

### Skema Alamat IP

| Host | Alamat IP  |
| ---- | ---------- |
| h1   | 10.0.0.1/8 |
| h2   | 10.0.0.2/8 |
| h3   | 10.0.0.3/8 |
| h4   | 10.0.0.4/8 |

Penggunaan subnet `/8` bertujuan memastikan seluruh host berada pada domain Layer-2 yang sama sehingga komunikasi tidak memerlukan router tambahan.

---

## Persiapan Lingkungan

### Membersihkan Sesi Sebelumnya

```bash
sudo mn -c
sudo killall osken-manager
```

### Menjalankan Controller

Contoh menjalankan controller multipath:

```bash
osken-manager SPF/controllers/multipath_spf.py --observe-links
```

### Menjalankan Topologi

Contoh menggunakan topologi Diamond:

```bash
sudo python3 SPF/topologies/topo-diamond_lab.py
```

---

## Prosedur Pengambilan Data

### 1. Pengukuran Latency Awal

Lakukan ping pertama untuk memicu proses route computation dan instalasi flow.

```bash
mininet> h1 ping -c 1 10.0.0.3
```

Catat waktu komputasi yang muncul pada log controller.

---

### 2. Pengambilan Statistik Port Awal

```bash
mininet> s2 ovs-ofctl dump-ports s2
mininet> s3 ovs-ofctl dump-ports s3
```

Data ini digunakan sebagai nilai awal sebelum pembebanan trafik.

---

### 3. Pengukuran Throughput

Jalankan server iperf3:

```bash
mininet> h3 iperf3 -s -p 5201 &
```

Jalankan client iperf3:

```bash
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -P 2 -p 5201
```

Nilai throughput diambil dari baris ringkasan output `SUM`.

---

### 4. Pengambilan Statistik Port Akhir

```bash
mininet> s2 ovs-ofctl dump-ports s2
mininet> s3 ovs-ofctl dump-ports s3
```

Selisih nilai byte counter sebelum dan sesudah pengujian digunakan untuk menghitung distribusi trafik pada masing-masing jalur.

---

## Algoritme yang Dievaluasi

### Dijkstra Multipath

Menggunakan algoritme Dijkstra sebagai dasar pencarian jalur terpendek dan mendukung distribusi trafik melalui OpenFlow Select Group.

### Bellman-Ford Multipath

Menggunakan algoritme Bellman-Ford untuk mendukung pencarian beberapa jalur dengan biaya yang sama melalui mekanisme ECMP.

### Suurballe Multipath

Menggunakan algoritme Suurballe untuk menghasilkan dua jalur edge-disjoint sehingga meningkatkan toleransi terhadap kegagalan link.

---

## Metrik Evaluasi

Beberapa metrik yang digunakan dalam penelitian ini meliputi:

* Waktu komputasi jalur.
* Throughput jaringan.
* Distribusi beban trafik.
* Efektivitas load balancing.
* Ketahanan terhadap kegagalan link.
* Jumlah flow OpenFlow yang terinstal.
* Pemanfaatan OpenFlow Group Table.

---

## Lisensi

Repositori ini dikembangkan untuk keperluan penelitian akademik dan tugas akhir mata kuliah Arsitektur Jaringan Modern.

Seluruh kode sumber dapat digunakan, dimodifikasi, dan dikembangkan lebih lanjut untuk keperluan pendidikan dan penelitian dengan tetap mencantumkan atribusi kepada pengembang asli.

## Referensi
Repositori Dasar: github.com/abazh/learn_sdn.
