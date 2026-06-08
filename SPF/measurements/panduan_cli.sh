# ================================================================
#  PANDUAN MININET CLI — PENGUKURAN METRIK EVALUASI
#  Latency | Throughput | Load Balancing
#  Dev Container + OSKen Controller (tanpa xterm)
#  Topologi: Diamond & Partial Mesh
# ================================================================
#
#  SETUP TERMINAL (buka 2 terminal di VS Code):
#
#  ┌──────────────┬──────────────────────────────────────────────┐
#  │ Terminal 1   │ sudo python3 SPF/topo_diamond.lab.py         │
#  │              │ → Mininet CLI aktif di sini (prompt: mininet>)│
#  ├──────────────┼──────────────────────────────────────────────┤
#  │ Terminal 2   │ osken-manager shortest_path.py               │
#  │              │ → OSKen controller berjalan                  │
#  └──────────────┴──────────────────────────────────────────────┘
#
#  PENTING:
#  - Semua perintah diketik di Terminal 1 (Mininet CLI)
#  - Tanda & di akhir perintah = jalankan di background
#    (CLI tetap bisa dipakai untuk perintah berikutnya)
#  - Tanpa & = foreground, hasil langsung muncul di layar
#  - Ulangi seluruh eksperimen untuk topologi Diamond
#    dan Partial Mesh secara terpisah
# ================================================================


# ================================================================
# LANGKAH 0 — CEK KONEKTIVITAS AWAL
# ================================================================
# Fungsi : memastikan semua host bisa berkomunikasi dan OSKen
#          sudah memasang flow entry yang benar di setiap switch.
#          WAJIB dilakukan sebelum eksperimen apapun.
# ================================================================

mininet> pingall

# Output yang diharapkan:
# *** Ping: testing ping reachability
# h1 -> h2 h3 h4
# h2 -> h1 h3 h4
# h3 -> h1 h2 h4
# h4 -> h1 h2 h3
# *** Results: 0% dropped (12/12 received)

# Jika ada yang drop → tunggu 3-5 detik lalu ulangi pingall


# ================================================================
# BAGIAN 1 — LATENSI (ping)
# ================================================================
#
# KONSEP:
#   ping mengirim paket ICMP echo request dari host sumber ke
#   host tujuan dan mengukur RTT (Round Trip Time).
#
#   Paket PERTAMA (icmp_seq=1) mencerminkan FLOW SETUP TIME
#   yaitu waktu OSKen menghitung multipath dan memasang flow
#   entry ke switch sebelum paket bisa diteruskan.
#
#   Paket selanjutnya (icmp_seq=2 dst) mencerminkan LATENSI
#   STEADY-STATE yaitu RTT setelah jalur sudah terbentuk.
#
#   Flag yang digunakan:
#   -c 30  = kirim 30 paket
#   -i 0.2 = interval 0.2 detik antar paket
# ================================================================


# ── SKENARIO IDLE ─────────────────────────────────────────────
# Fungsi : mengukur latensi murni tanpa beban trafik lain.
#          Tidak perlu menjalankan apapun sebelumnya.

mininet> h1 ping -c 30 -i 0.2 10.0.0.3
mininet> h1 ping -c 30 -i 0.2 10.0.0.4
mininet> h2 ping -c 30 -i 0.2 10.0.0.3
mininet> h2 ping -c 30 -i 0.2 10.0.0.4


# ── SKENARIO LOADED ───────────────────────────────────────────
# Fungsi : mengukur latensi saat jaringan sedang menanggung
#          beban trafik background dari dua host sekaligus.

# [1] Jalankan server iperf3 di background
mininet> h3 iperf3 -s -p 5201 &
mininet> h4 iperf3 -s -p 5201 &

# [2] Bangkitkan trafik background
#     Fungsi: h1 mengirim 5 Mbps ke h3, h2 mengirim 5 Mbps ke h4,
#             keduanya berjalan 120 detik di background.
mininet> h1 iperf3 -c 10.0.0.3 -t 120 -b 5M -p 5201 &
mininet> h2 iperf3 -c 10.0.0.4 -t 120 -b 5M -p 5201 &

# [3] Tunggu background traffic stabil
mininet> h1 sleep 3

# [4] Ukur latensi (foreground, hasil langsung muncul)
mininet> h1 ping -c 30 -i 0.2 10.0.0.3
mininet> h2 ping -c 30 -i 0.2 10.0.0.4

# [5] Hentikan semua trafik dan server
mininet> h1 pkill iperf3
mininet> h2 pkill iperf3
mininet> h3 pkill iperf3
mininet> h4 pkill iperf3


# ── CARA BACA OUTPUT PING ─────────────────────────────────────
#
# Contoh output:
# ---------------------------------------------------------------
# 64 bytes from 10.0.0.3: icmp_seq=1  time=15.4  ms   ← FLOW SETUP TIME
# 64 bytes from 10.0.0.3: icmp_seq=2  time=0.187 ms   ← steady-state
# 64 bytes from 10.0.0.3: icmp_seq=3  time=0.128 ms
# ...
# rtt min/avg/max/mdev = 0.119/0.676/15.355/2.726 ms
# ---------------------------------------------------------------
#
# Yang diambil:
#   Flow Setup Time  → nilai time= pada icmp_seq=1
#   Min              → dari baris rtt min/avg/max/mdev
#   Avg steady-state → JANGAN gunakan avg dari ringkasan karena
#                      sudah tercemari icmp_seq=1 yang besar.
#                      Hitung manual rata-rata icmp_seq=2 s/d 30.
#   Max              → dari baris rtt min/avg/max/mdev
#   Mdev             → dari baris rtt min/avg/max/mdev


# ── TABEL 1: LATENSI MENTAH ───────────────────────────────────
#
# Topologi: _________________ (Diamond / Partial Mesh)
#
# ┌──────────┬──────┬──────┬───────────────────┬────────┬──────────────────┬────────┬────────┬──────────┐
# │ Skenario │ Src  │ Dst  │ Flow Setup Time   │ Min    │ Avg Steady-State │ Max    │ Mdev   │ Loss (%) │
# │          │      │      │ icmp_seq=1 (ms)   │  (ms)  │ icmp_seq=2+ (ms) │  (ms)  │  (ms)  │          │
# ├──────────┼──────┼──────┼───────────────────┼────────┼──────────────────┼────────┼────────┼──────────┤
# │ idle     │ h1   │ h3   │                   │        │                  │        │        │          │
# │ idle     │ h1   │ h4   │                   │        │                  │        │        │          │
# │ idle     │ h2   │ h3   │                   │        │                  │        │        │          │
# │ idle     │ h2   │ h4   │                   │        │                  │        │        │          │
# │ loaded   │ h1   │ h3   │                   │        │                  │        │        │          │
# │ loaded   │ h2   │ h4   │                   │        │                  │        │        │          │
# └──────────┴──────┴──────┴───────────────────┴────────┴──────────────────┴────────┴────────┴──────────┘


# ================================================================
# BAGIAN 2 — THROUGHPUT (iperf3)
# ================================================================
#
# KONSEP:
#   Server iperf3 (penerima) dijalankan di h3 dan h4.
#   Client iperf3 (pengirim) dijalankan di h1 dan h2.
#   Server HARUS dijalankan lebih dulu dengan & (background).
#
#   Untuk menghindari konflik saat skenario loaded, gunakan
#   DUA port berbeda:
#     Port 5201 → khusus trafik background
#     Port 5202 → khusus pengukuran throughput
#
#   Flag yang digunakan:
#   -t 15  = durasi pengiriman 15 detik
#   -P 2/4 = jumlah stream paralel (throughput agregat)
#   -u     = mode UDP
#   -b 10M = target bitrate UDP 10 Mbps
# ================================================================


# ── SKENARIO IDLE ─────────────────────────────────────────────

# [1] Jalankan server
mininet> h3 iperf3 -s -p 5201 &
mininet> h4 iperf3 -s -p 5201 &

# [2] Ukur TCP — satu per satu, catat tiap output

# TCP 1 stream
# Fungsi: kapasitas satu jalur TCP dari h1 ke h3 tanpa beban.
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -p 5201

# TCP 2 stream paralel
# Fungsi: -P 2 membuka 2 koneksi TCP sekaligus, total throughput
#         = gabungan kedua stream (throughput agregat).
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -P 2 -p 5201

# TCP 4 stream paralel
# Fungsi: -P 4 menekan jalur lebih keras, mendekati kapasitas max.
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -P 4 -p 5201

# UDP 10 Mbps
# Fungsi: -u mode UDP, tidak ada retransmisi seperti TCP.
#         Menghasilkan metrik jitter dan packet loss.
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -u -b 10M -p 5201

# [3] Hentikan server
mininet> h3 pkill iperf3
mininet> h4 pkill iperf3


# ── SKENARIO LOADED ───────────────────────────────────────────

# [1] Jalankan server di DUA port
#     Port 5201 = untuk trafik background
#     Port 5202 = untuk pengukuran (agar tidak konflik)
mininet> h3 iperf3 -s -p 5201 &
mininet> h4 iperf3 -s -p 5201 &
mininet> h3 iperf3 -s -p 5202 &
mininet> h4 iperf3 -s -p 5202 &

# [2] Bangkitkan trafik background ke port 5201
mininet> h1 iperf3 -c 10.0.0.3 -t 120 -b 5M -p 5201 &
mininet> h2 iperf3 -c 10.0.0.4 -t 120 -b 5M -p 5201 &
mininet> h1 sleep 3

# [3] Ukur throughput ke port 5202 (tidak konflik dengan background)
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -P 2 -p 5202
mininet> h2 iperf3 -c 10.0.0.4 -t 15 -u -b 10M -p 5202

# [4] Hentikan semua
mininet> h1 pkill iperf3
mininet> h2 pkill iperf3
mininet> h3 pkill iperf3
mininet> h4 pkill iperf3


# ── CARA BACA OUTPUT IPERF3 ───────────────────────────────────
#
# TCP 1 stream → ambil baris "receiver":
# ---------------------------------------------------------------
# [ ID] Interval        Transfer     Bitrate         Retr
# [  5] 0.00-15.00 sec  16.5 MBytes  9.24 Mbits/sec   10  sender
# [  5] 0.00-15.00 sec  16.3 MBytes  9.13 Mbits/sec       receiver  ← AMBIL
# ---------------------------------------------------------------
#
# TCP -P 2 atau -P 4 → ambil baris "[SUM] receiver":
# ---------------------------------------------------------------
# [  5] 0.00-15.00 sec  ...  sender
# [  7] 0.00-15.00 sec  ...  sender
# [SUM] 0.00-15.00 sec  32.8 MBytes  18.3 Mbits/sec      receiver  ← AMBIL
# ---------------------------------------------------------------
#
# UDP → ambil baris "receiver" (satu-satunya baris ringkasan):
# ---------------------------------------------------------------
# [ ID] Interval     Transfer   Bitrate     Jitter   Lost/Total  Lost%
# [  5] 0.00-15.00s  17.9 MB   10.0 Mbps  0.017 ms  0/12949     0%
#                                           ↑ AMBIL   ↑ AMBIL    ↑ AMBIL
#                               ↑ AMBIL (Throughput)
# ---------------------------------------------------------------


# ── TABEL 2: THROUGHPUT MENTAH ────────────────────────────────
#
# Topologi: _________________ (Diamond / Partial Mesh)
# Isi dari baris receiver (TCP) atau baris ringkasan (UDP).
# Untuk -P > 1, ambil baris [SUM] receiver.
#
# ┌──────────┬──────┬──────┬───────┬─────────┬────────────┬──────────┬──────────┐
# │ Skenario │ Src  │ Dst  │ Proto │ Streams │ Throughput │ Jitter   │ Loss (%) │
# │          │      │      │       │  (-P)   │   (Mbps)   │   (ms)   │  UDP     │
# ├──────────┼──────┼──────┼───────┼─────────┼────────────┼──────────┼──────────┤
# │ idle     │ h1   │ h3   │ TCP   │   1     │            │  N/A     │  N/A     │
# │ idle     │ h1   │ h3   │ TCP   │   2     │            │  N/A     │  N/A     │
# │ idle     │ h1   │ h3   │ TCP   │   4     │            │  N/A     │  N/A     │
# │ idle     │ h1   │ h3   │ UDP   │   1     │            │          │          │
# │ loaded   │ h1   │ h3   │ TCP   │   2     │            │  N/A     │  N/A     │
# │ loaded   │ h2   │ h4   │ UDP   │   1     │            │          │          │
# └──────────┴──────┴──────┴───────┴─────────┴────────────┴──────────┴──────────┘


# ================================================================
# BAGIAN 3 — LOAD BALANCING (dpctl dump-ports)
# ================================================================
#
# KONSEP:
#   OVS menyimpan counter TX bytes per port di setiap switch.
#   Kita baca counter SEBELUM trafik (BEFORE) dan SESUDAH (AFTER),
#   hitung selisihnya (delta) = byte yang melewati jalur itu.
#
#   Gunakan dpctl karena ovs-ofctl tidak bisa dijalankan
#   dari dalam namespace switch di Mininet CLI.
#
#   Fokus pada switch S1 karena S1 adalah titik distribusi:
#   - eth3 = Jalur A (Diamond) / Jalur 1 (Partial Mesh)
#   - eth4 = Jalur B (Diamond) / Jalur 2 (Partial Mesh)
#
#   Bobot distribusi OSKen Anda: 70% (eth3) : 30% (eth4)
#   Hasil load balance yang diharapkan bukan 50:50 melainkan
#   mendekati 70:30 — ini adalah perilaku yang benar.
# ================================================================


# ── STEP 1: Snapshot BEFORE (saat idle) ──────────────────────
# Fungsi : membaca nilai tx bytes awal semua switch.
#          Lakukan saat belum ada trafik iperf3 berjalan.

mininet> dpctl dump-ports -O OpenFlow13

# Contoh output (fokus pada s1):
# ---------------------------------------------------------------
# *** s1 -----------------------------------------------------------
#   port  1: rx pkts=..., bytes=..., ...
#             tx pkts=48,  bytes=3936, ...   ← catat tx bytes port 1
#   port  2: rx pkts=..., bytes=..., ...
#             tx pkts=50,  bytes=4100, ...   ← catat tx bytes port 2
#   port  3: rx pkts=..., bytes=..., ...
#             tx pkts=45,  bytes=3690, ...   ← catat tx bytes port 3 (Jalur A/1)
#   port  4: rx pkts=..., bytes=..., ...
#             tx pkts=20,  bytes=1640, ...   ← catat tx bytes port 4 (Jalur B/2)
# ---------------------------------------------------------------
# Catat tx bytes TIAP PORT dari s1 (dan s4 untuk Diamond,
# atau s6 untuk Partial Mesh jika ingin verifikasi sisi penerima)


# ── STEP 2: Bangkitkan trafik dari kedua host ─────────────────
# Fungsi : h1 dan h2 mengirim trafik paralel agar switch
#          mendistribusikan ke jalur-jalur alternatif.

mininet> h3 iperf3 -s -p 5201 &
mininet> h4 iperf3 -s -p 5201 &
mininet> h1 iperf3 -c 10.0.0.3 -t 60 -b 5M -p 5201 &
mininet> h2 iperf3 -c 10.0.0.4 -t 60 -b 5M -p 5201 &

# Tunggu 30 detik agar counter terakumulasi cukup banyak
mininet> h1 sleep 30


# ── STEP 3: Snapshot AFTER ────────────────────────────────────
# Fungsi : membaca nilai tx bytes setelah 30 detik trafik.

mininet> dpctl dump-ports -O OpenFlow13


# ── STEP 4: Hentikan semua trafik ─────────────────────────────
mininet> h1 pkill iperf3
mininet> h2 pkill iperf3
mininet> h3 pkill iperf3
mininet> h4 pkill iperf3


# ── STEP 5: Hitung delta dan persentase (manual/kalkulator) ───
#
# Fokus pada port 3 dan port 4 di switch s1:
#
# Rumus:
#   delta_port3  = tx_bytes_AFTER(port3) - tx_bytes_BEFORE(port3)
#   delta_port4  = tx_bytes_AFTER(port4) - tx_bytes_BEFORE(port4)
#   total_delta  = delta_port3 + delta_port4
#   pct_port3    = (delta_port3 / total_delta) × 100  → Jalur A/1
#   pct_port4    = (delta_port4 / total_delta) × 100  → Jalur B/2
#   imbalance    = pct_port3 - pct_port4
#
# Contoh perhitungan:
#   BEFORE: port3 tx = 3.690 bytes,      port4 tx = 1.640 bytes
#   AFTER:  port3 tx = 10.503.690 bytes, port4 tx = 4.501.640 bytes
#
#   delta_port3 = 10.503.690 - 3.690   = 10.500.000 bytes = 10,5 MB
#   delta_port4 = 4.501.640  - 1.640   =  4.500.000 bytes =  4,5 MB
#   total_delta = 10.500.000 + 4.500.000 = 15.000.000 bytes
#
#   pct_port3 = (10.500.000 / 15.000.000) × 100 = 70%  ← Jalur A/1
#   pct_port4 = ( 4.500.000 / 15.000.000) × 100 = 30%  ← Jalur B/2
#   imbalance = 70 - 30 = 40%  → sesuai bobot OSKen 70:30


# ── TABEL 3: LOAD BALANCING MENTAH ───────────────────────────
#
# Topologi: _________________ (Diamond / Partial Mesh)
# Fokus pada switch S1, port 3 (Jalur A/1) dan port 4 (Jalur B/2)
#
# ┌──────────────┬───────┬────────┬──────────────┬──────────────┬──────────────┬──────────┬──────────┬──────────────┐
# │ Topologi     │ Switch│ Port   │ Jalur        │ TX Bytes     │ TX Bytes     │ Delta    │ Delta    │ % dari Total │
# │              │       │        │              │ BEFORE       │ AFTER        │ (bytes)  │ (MB)     │              │
# ├──────────────┼───────┼────────┼──────────────┼──────────────┼──────────────┼──────────┼──────────┼──────────────┤
# │ Diamond      │ s1    │ port 3 │ Jalur A      │              │              │          │          │              │
# │ Diamond      │ s1    │ port 4 │ Jalur B      │              │              │          │          │              │
# ├──────────────┼───────┼────────┼──────────────┼──────────────┼──────────────┼──────────┼──────────┼──────────────┤
# │ Partial Mesh │ s1    │ port 3 │ Jalur 1      │              │              │          │          │              │
# │ Partial Mesh │ s1    │ port 4 │ Jalur 2      │              │              │          │          │              │
# └──────────────┴───────┴────────┴──────────────┴──────────────┴──────────────┴──────────┴──────────┴──────────────┘
#
# Imbalance Diamond      = pct_port3 - pct_port4 = _______%
# Imbalance Partial Mesh = pct_port3 - pct_port4 = _______%
#
# Interpretasi (berdasarkan bobot OSKen 70:30):
#   Mendekati 70:30 → distribusi SESUAI BOBOT (load balancing bekerja)
#   Mendekati 100:0 → single-path, load balancing TIDAK bekerja
#   Tepat 50:50     → ECMP tanpa bobot (tidak sesuai konfigurasi)


# ================================================================
# URUTAN LENGKAP EKSPERIMEN (ringkasan copy-paste)
# ================================================================

# [0] Cek konektivitas
mininet> pingall

# ── LATENSI ─────────────────────────────────────────────────

# [1] Idle
mininet> h1 ping -c 30 -i 0.2 10.0.0.3
mininet> h1 ping -c 30 -i 0.2 10.0.0.4
mininet> h2 ping -c 30 -i 0.2 10.0.0.3
mininet> h2 ping -c 30 -i 0.2 10.0.0.4

# [2] Loaded
mininet> h3 iperf3 -s -p 5201 &
mininet> h4 iperf3 -s -p 5201 &
mininet> h1 iperf3 -c 10.0.0.3 -t 120 -b 5M -p 5201 &
mininet> h2 iperf3 -c 10.0.0.4 -t 120 -b 5M -p 5201 &
mininet> h1 sleep 3
mininet> h1 ping -c 30 -i 0.2 10.0.0.3
mininet> h2 ping -c 30 -i 0.2 10.0.0.4
mininet> h1 pkill iperf3
mininet> h2 pkill iperf3
mininet> h3 pkill iperf3
mininet> h4 pkill iperf3

# ── THROUGHPUT ──────────────────────────────────────────────

# [3] Idle
mininet> h3 iperf3 -s -p 5201 &
mininet> h4 iperf3 -s -p 5201 &
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -p 5201
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -P 2 -p 5201
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -P 4 -p 5201
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -u -b 10M -p 5201
mininet> h3 pkill iperf3
mininet> h4 pkill iperf3

# [4] Loaded
mininet> h3 iperf3 -s -p 5201 &
mininet> h4 iperf3 -s -p 5201 &
mininet> h3 iperf3 -s -p 5202 &
mininet> h4 iperf3 -s -p 5202 &
mininet> h1 iperf3 -c 10.0.0.3 -t 120 -b 5M -p 5201 &
mininet> h2 iperf3 -c 10.0.0.4 -t 120 -b 5M -p 5201 &
mininet> h1 sleep 3
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -P 2 -p 5202
mininet> h2 iperf3 -c 10.0.0.4 -t 15 -u -b 10M -p 5202
mininet> h1 pkill iperf3
mininet> h2 pkill iperf3
mininet> h3 pkill iperf3
mininet> h4 pkill iperf3

# ── LOAD BALANCING ──────────────────────────────────────────

# [5] Snapshot BEFORE
mininet> dpctl dump-ports -O OpenFlow13

# [6] Bangkitkan trafik
mininet> h3 iperf3 -s -p 5201 &
mininet> h4 iperf3 -s -p 5201 &
mininet> h1 iperf3 -c 10.0.0.3 -t 60 -b 5M -p 5201 &
mininet> h2 iperf3 -c 10.0.0.4 -t 60 -b 5M -p 5201 &
mininet> h1 sleep 30

# [7] Snapshot AFTER
mininet> dpctl dump-ports -O OpenFlow13

# [8] Hentikan semua
mininet> h1 pkill iperf3
mininet> h2 pkill iperf3
mininet> h3 pkill iperf3
mininet> h4 pkill iperf3
