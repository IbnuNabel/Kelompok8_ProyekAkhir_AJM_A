# Ringkasan Implementasi: Controller Multipath Suurballe

Pekerjaan untuk mengintegrasikan algoritma Suurballe telah selesai dilakukan. Berikut ini adalah dokumentasi perubahan yang baru saja dibuat untuk bagian Sandhika di repositori.

## Perubahan yang Dilakukan

Kita telah mengimplementasikan logika OpenFlow controller menggunakan `os_ken` dengan algoritma *routing* Suurballe untuk mencari jalur paralel (*multipath*).

### 1. File [multipath_suurballe.py](SPF/controllers/multipath_suurballe.py) [NEW]
File ini adalah *script* utama yang akan dijalankan oleh *controller* OSKen:
- **Class `MultipathSuurballeController`**: Mewarisi fungsionalitas dari `SPFBaseController`.
- **Integrasi `suurballe_edge_disjoint`**: Di dalam fungsi `compute_multipath`, pencarian rute tidak lagi menggunakan BFS. Controller kini memanggil fungsi algoritma Suurballe bawaan, mengubah struktur data kembalian (dari sekumpulan node menjadi sekumpulan list *in_port/out_port*) sehingga dapat dimengerti oleh tabel OpenFlow.
- **Logika *Select Group***: Fungsi `install_multipath` menyalin konsep yang dianjurkan ketuamu. Jika terdapat dua jalur (*path*) yang dihasilkan oleh Suurballe, Controller akan memasang *SELECT group* pada *switch ingress* dengan *weight* (pembobotan) `70:30` sesuai arahan eksperimen di template.
- **Pemasangan Aturan Unicast**: *Flow* biasa (*unicast*) diteruskan dari *ingress* ke tiap-tiap *switch transit* melalui *port* yang valid.
- **Entrypoint (`__main__`)**: Kode sudah siap dieksekusi dengan *runner* osken secara langsung, tidak perlu menulis *script bash* manual di Mininet kecuali jika memang dianjurkan oleh ketua.

### 2. File [suurballe.py](SPF/algorithms/suurballe.py) [VERIFIED]
File ini dibiarkan apa adanya karena fungsinya sudah benar dan sudah sesuai untuk mencari 2 *edge-disjoint paths*. Controller langsung melakukan komputasi menggunakan skrip algoritma yang ada.

## Instruksi Pengujian (*Verification*)

Untuk membuktikan kodenya berjalan, kamu bisa melakukan tes sederhana bersama tim (Aero / Ketua):

1. **Jalankan Topologi Mininet**:
   Buka terminal di mesin virtual Mininet, lalu eksekusi langsung script topologi sebagai root. Kamu bisa memilih antara topologi Diamond (2 jalur) atau Partial Mesh (multijalur yang lebih kompleks):

   **Untuk Topologi Diamond**:
   ```bash
   sudo python3 SPF/topologies/topo-diamond_lab.py
   ```
   **Untuk Topologi Partial Mesh**:
   ```bash
   sudo python3 SPF/topologies/topo-partial_mesh_lab.py
   ```

2. **Jalankan Controller Suurballe**:
   Di terminal baru (atau pane baru jika menggunakan tmux/screen), jalankan file controller dengan `osken-manager` atau python secara langsung:
   ```bash
   python3 SPF/controllers/multipath_suurballe.py
   ```

3. **Verifikasi *Group Flow* di OVS**:
   Kembali ke terminal tempat Mininet berjalan. Cek apakah grup *multipath* Suurballe berhasil dipasang di *switch ingress* utama (misal `s1`):
   ```bash
   mininet> sh ovs-ofctl dump-groups s1 -O OpenFlow13
   ```
   *Deskripsi: Perintah ini mengecek tabel grup di switch s1. Kamu seharusnya melihat output `type=select` dengan bobot yang sudah diset (weight=7 dan weight=3).*

4. **Tes Konektivitas (Ping)**:
   Lakukan tes koneksi antar *host* untuk memastikan semua jalur terhubung dengan baik:
   ```bash
   mininet> pingall
   ```
   *Deskripsi: `pingall` akan memastikan setiap host (h1, h2, h3, h4) bisa saling menjangkau tanpa ada packet loss. Ini membuktikan bahwa rute Suurballe berhasil dibuat ke semua titik.*

5. **Tes Performa dan *Load Balancing* (iPerf)**:
   Buat banyak koneksi paralel antara `h1` dan `h4` untuk melihat pembagian beban trafik (meskipun ping hanya dikirim ke satu jalur karena hashing MAC/IP yang sama, kita bisa menguji stabilitas bandwidth):
   ```bash
   mininet> iperf h1 h4
   ```
   *Deskripsi: Menjalankan tes bandwidth. Setelah tes ini, kamu bisa memeriksa byte_count di masing-masing rute (port 3 dan port 4 pada s1) dengan perintah:*
   ```bash
   mininet> sh ovs-ofctl dump-flows s1 -O OpenFlow13
   ```
   *Kamu akan bisa membandingkan n_bytes yang lewat, apakah distribusinya sesuai dengan rasio pembobotan 70:30.*

> [!TIP]
> Karena tugas bagianmu sudah diimplementasi semua, kamu bisa langsung berkoordinasi dengan Aero untuk melakukan komparasi performa antara Controller buatanmu dengan Dijkstra / Bellman-Ford buatan teman-temanmu!
