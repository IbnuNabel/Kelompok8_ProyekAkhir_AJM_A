# ============================================================
#  PANDUAN PERINTAH MANUAL - MININET CLI
#  Untuk Dev Container + OSKen Controller
# ============================================================
#
#  ALUR KERJA:
#    Terminal 1 : jalankan topologi  → sudo python3 SPF/topo_diamond.lab.py
#    Terminal 2 : jalankan OSKen     → osken-manager shortest_path.py
#    Terminal 3 : (Mininet CLI aktif di Terminal 1)
#
# ============================================================


# ============================================================
# BAGIAN 1 — CEK KONEKTIVITAS DASAR
# ============================================================

mininet> pingall
# Memastikan semua host bisa saling berkomunikasi sebelum eksperimen

mininet> h1 ip addr
# Melihat IP h1 (pastikan sesuai konfigurasi topologi)

mininet> net
# Melihat struktur jaringan: interface tiap host & switch


# ============================================================
# BAGIAN 2 — PENGUKURAN LATENSI (ping)
# ============================================================
# Format : h<src> ping -c <jumlah> -i <interval> <IP_tujuan>
# -c  = jumlah paket yang dikirim
# -i  = interval antar paket (detik); 0.2 = 5 pkt/s
# -q  = quiet mode, hanya tampilkan ringkasan
#
# Catat kolom: min/avg/max/mdev (ms) dan packet loss %
# ============================================================

# ── KONDISI IDLE (tidak ada trafik lain) ──────────────────

# Diamond: h1 -> h3 (melewati s1-s2-s4 atau s1-s3-s4)
mininet> h1 ping -c 30 -i 0.2 10.0.0.3

# Diamond: h1 -> h4
mininet> h1 ping -c 30 -i 0.2 10.0.0.4

# Diamond: h2 -> h3
mininet> h2 ping -c 30 -i 0.2 10.0.0.3

# Partial Mesh: h1 -> h3 (melewati salah satu dari 3 jalur)
mininet> h1 ping -c 30 -i 0.2 10.0.0.3

# Partial Mesh: h2 -> h4
mininet> h2 ping -c 30 -i 0.2 10.0.0.4


# ── KONDISI LOADED (dengan trafik background) ─────────────
# Langkah:
#   1. Buka xterm h1 dan h3 untuk background traffic
#   2. Jalankan ping dari h2 secara bersamaan

# Buka terminal terpisah untuk host
mininet> xterm h1 h2 h3 h4

# Di xterm h3: jalankan iperf3 server
iperf3 -s

# Di xterm h4: jalankan iperf3 server
iperf3 -s

# Di xterm h1: bangkitkan trafik background ke h3
iperf3 -c 10.0.0.3 -t 120 -b 4M &

# Di xterm h2: bangkitkan trafik background ke h4
iperf3 -c 10.0.0.4 -t 120 -b 4M &

# Di Mininet CLI: ukur latensi saat loaded
mininet> h1 ping -c 30 -i 0.2 10.0.0.3
mininet> h2 ping -c 30 -i 0.2 10.0.0.4


# ============================================================
# BAGIAN 3 — PENGUKURAN THROUGHPUT (iperf3)
# ============================================================
# Format server : iperf3 -s
# Format client : iperf3 -c <IP_server> -t <durasi> [opsi]
#
# Opsi penting:
#   -t  = durasi pengiriman (detik)
#   -P  = jumlah parallel stream (throughput agregat)
#   -u  = mode UDP
#   -b  = target bitrate UDP (contoh: 10M = 10 Mbps)
#   -J  = output JSON (mudah di-copy ke spreadsheet)
#
# Catat kolom: Bitrate (Mbps), Transfer (MB), Jitter (UDP),
#              Lost/Total (UDP)
# ============================================================

# ── Jalankan server di h3 (di xterm h3) ──────────────────
iperf3 -s

# ── TCP — 1 stream, idle ──────────────────────────────────
mininet> h1 iperf3 -c 10.0.0.3 -t 15

# ── TCP — 2 stream paralel (throughput agregat) ───────────
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -P 2

# ── TCP — 4 stream paralel ────────────────────────────────
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -P 4

# ── UDP — ukur jitter & packet loss ──────────────────────
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -u -b 10M

# ── TCP loaded: jalankan setelah background traffic aktif ─
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -P 2

# ── Output JSON (untuk disalin ke spreadsheet) ────────────
mininet> h1 iperf3 -c 10.0.0.3 -t 15 -J


# ============================================================
# BAGIAN 4 — KESEIMBANGAN BEBAN (OVS port stats)
# ============================================================
# Membaca counter byte per port switch OVS.
# Lakukan SEBELUM dan SESUDAH periode trafik, lalu hitung selisih.
#
# Diamond   : pantau s2 (Jalur A) dan s3 (Jalur B)
# Partial   : pantau s2 (Jalur 1), s3 (Jalur 2), s5 (Jalur 3)
# ============================================================

# Snapshot SEBELUM trafik dimulai
mininet> s2 ovs-ofctl dump-ports s2
mininet> s3 ovs-ofctl dump-ports s3
mininet> s5 ovs-ofctl dump-ports s5     # khusus Partial Mesh

# → Catat nilai "tx bytes=" untuk tiap port

# Jalankan trafik (di xterm)
# h1: iperf3 -c 10.0.0.3 -t 30 -b 5M &
# h2: iperf3 -c 10.0.0.4 -t 30 -b 5M &

# Tunggu 20-30 detik, lalu snapshot SESUDAH
mininet> s2 ovs-ofctl dump-ports s2
mininet> s3 ovs-ofctl dump-ports s3
mininet> s5 ovs-ofctl dump-ports s5

# → Selisih tx bytes = volume trafik per jalur
# → Hitung persentase: (delta_s2 / (delta_s2 + delta_s3)) * 100


# ============================================================
# BAGIAN 5 — MELIHAT FLOW TABLE (opsional, untuk verifikasi)
# ============================================================
# Memverifikasi apakah OSKen memasang flow entry yang benar
# ============================================================

mininet> s1 ovs-ofctl dump-flows s1
mininet> s2 ovs-ofctl dump-flows s2

# Melihat statistik flow (byte count per rule)
mininet> s1 ovs-ofctl dump-flows s1 --stats


# ============================================================
# TEMPLATE TABEL MENTAH HASIL
# ============================================================
#
# TABEL 1 - LATENSI (ms)
# ┌──────────┬──────┬──────┬────────┬────────┬────────┬────────┬──────────┐
# │ Kondisi  │ Src  │ Dst  │ Min    │ Avg    │ Max    │ Mdev   │ Loss (%) │
# ├──────────┼──────┼──────┼────────┼────────┼────────┼────────┼──────────┤
# │ idle     │ h1   │ h3   │        │        │        │        │          │
# │ idle     │ h1   │ h4   │        │        │        │        │          │
# │ idle     │ h2   │ h3   │        │        │        │        │          │
# │ idle     │ h2   │ h4   │        │        │        │        │          │
# │ loaded   │ h1   │ h3   │        │        │        │        │          │
# │ loaded   │ h2   │ h4   │        │        │        │        │          │
# └──────────┴──────┴──────┴────────┴────────┴────────┴────────┴──────────┘
#
# TABEL 2 - THROUGHPUT (iperf3)
# ┌──────────┬──────┬──────┬──────┬─────────┬────────────┬───────────┬──────────┐
# │ Kondisi  │ Src  │ Dst  │Proto │ Streams │ Throughput │ Jitter    │ Lost (%) │
# │          │      │      │      │         │ (Mbps)     │ ms (UDP)  │          │
# ├──────────┼──────┼──────┼──────┼─────────┼────────────┼───────────┼──────────┤
# │ idle     │ h1   │ h3   │ TCP  │ 1       │            │ N/A       │ N/A      │
# │ idle     │ h1   │ h3   │ TCP  │ 2       │            │ N/A       │ N/A      │
# │ idle     │ h1   │ h3   │ TCP  │ 4       │            │ N/A       │ N/A      │
# │ idle     │ h1   │ h3   │ UDP  │ 1       │            │           │          │
# │ loaded   │ h1   │ h3   │ TCP  │ 2       │            │ N/A       │ N/A      │
# │ loaded   │ h1   │ h3   │ UDP  │ 1       │            │           │          │
# └──────────┴──────┴──────┴──────┴─────────┴────────────┴───────────┴──────────┘
#
# TABEL 3 - KESEIMBANGAN BEBAN
# ┌──────────────┬────────┬────────┬──────────────┬──────────┬──────────────┐
# │ Topologi     │ Switch │ Jalur  │ Delta Bytes  │ Delta MB │ % dari Total │
# ├──────────────┼────────┼────────┼──────────────┼──────────┼──────────────┤
# │ Diamond      │ s2     │ Jalur A│              │          │              │
# │ Diamond      │ s3     │ Jalur B│              │          │              │
# │ Partial Mesh │ s2     │ Jalur 1│              │          │              │
# │ Partial Mesh │ s3     │ Jalur 2│              │          │              │
# │ Partial Mesh │ s5     │ Jalur 3│              │          │              │
# └──────────────┴────────┴────────┴──────────────┴──────────┴──────────────┘
