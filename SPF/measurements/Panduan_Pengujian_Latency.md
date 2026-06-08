# Panduan Menghitung Latency (ms)
 
 ## 1. Tahap Pengambilan Data
**1. Jalankan mininet dengan topologi Partial Mesh**
**2. Lakukan ping dengan command berikut pada mininet**
```bash

mininet > h1 ping h4 -c 10

```
```bash

mininet > h2 ping h3 -c 10

```
> Notes: Terdapat 2 data latency yang perlu diambil untuk setiap topologi dan controller, latency untuk jalur **h1 ke h4** serta **h2 ke h3**

**3. Simpan data hasil ping lalu restart mininet serta controller**
**4. Lakukan kembali tahap 2 hingga 5 kali iterasi**
**5. Lakukan tahap 2 hingga 4 untuk mengambil data dari h1 ke h4 dan h2 ke h3 untuk setiap controller**

## 2. Tahap Perhitungan Data
> Contoh data
```bash
mininet> h2 ping h3 -c 10
PING 10.0.0.3 (10.0.0.3) 56(84) bytes of data.
64 bytes from 10.0.0.3: icmp_seq=1 ttl=64 time=30.2 ms
64 bytes from 10.0.0.3: icmp_seq=2 ttl=64 time=22.2 ms
64 bytes from 10.0.0.3: icmp_seq=3 ttl=64 time=9.85 ms
64 bytes from 10.0.0.3: icmp_seq=4 ttl=64 time=9.22 ms
64 bytes from 10.0.0.3: icmp_seq=5 ttl=64 time=8.81 ms
64 bytes from 10.0.0.3: icmp_seq=6 ttl=64 time=8.69 ms
64 bytes from 10.0.0.3: icmp_seq=7 ttl=64 time=9.18 ms
64 bytes from 10.0.0.3: icmp_seq=8 ttl=64 time=8.63 ms
64 bytes from 10.0.0.3: icmp_seq=9 ttl=64 time=8.68 ms
64 bytes from 10.0.0.3: icmp_seq=10 ttl=64 time=8.61 ms

--- 10.0.0.3 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9013ms
rtt min/avg/max/mdev = 8.607/12.401/30.164/7.123 ms | 10.43 (nilai Avg)

mininet> h2 ping h3 -c 10
PING 10.0.0.3 (10.0.0.3) 56(84) bytes of data.
64 bytes from 10.0.0.3: icmp_seq=1 ttl=64 time=46.4 ms
64 bytes from 10.0.0.3: icmp_seq=2 ttl=64 time=18.1 ms
64 bytes from 10.0.0.3: icmp_seq=3 ttl=64 time=9.94 ms
64 bytes from 10.0.0.3: icmp_seq=4 ttl=64 time=9.14 ms
64 bytes from 10.0.0.3: icmp_seq=5 ttl=64 time=8.73 ms
64 bytes from 10.0.0.3: icmp_seq=6 ttl=64 time=8.72 ms
64 bytes from 10.0.0.3: icmp_seq=7 ttl=64 time=8.68 ms
64 bytes from 10.0.0.3: icmp_seq=8 ttl=64 time=9.33 ms
64 bytes from 10.0.0.3: icmp_seq=9 ttl=64 time=9.26 ms
64 bytes from 10.0.0.3: icmp_seq=10 ttl=64 time=8.78 ms

--- 10.0.0.3 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9015ms
rtt min/avg/max/mdev = 8.681/13.711/46.444/11.243 ms | 10.075 (nilai Avg)

mininet> h2 ping h3 -c 10
PING 10.0.0.3 (10.0.0.3) 56(84) bytes of data.
64 bytes from 10.0.0.3: icmp_seq=1 ttl=64 time=37.1 ms
64 bytes from 10.0.0.3: icmp_seq=2 ttl=64 time=14.7 ms
64 bytes from 10.0.0.3: icmp_seq=3 ttl=64 time=9.68 ms
64 bytes from 10.0.0.3: icmp_seq=4 ttl=64 time=9.63 ms
64 bytes from 10.0.0.3: icmp_seq=5 ttl=64 time=8.76 ms
64 bytes from 10.0.0.3: icmp_seq=6 ttl=64 time=9.38 ms
64 bytes from 10.0.0.3: icmp_seq=7 ttl=64 time=9.17 ms
64 bytes from 10.0.0.3: icmp_seq=8 ttl=64 time=8.70 ms
64 bytes from 10.0.0.3: icmp_seq=9 ttl=64 time=9.47 ms
64 bytes from 10.0.0.3: icmp_seq=10 ttl=64 time=9.00 ms

--- 10.0.0.3 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9014ms
rtt min/avg/max/mdev = 8.699/12.558/37.108/8.351 ms | 9.832 (nilai Avg)

mininet> h2 ping h3 -c 10
PING 10.0.0.3 (10.0.0.3) 56(84) bytes of data.
64 bytes from 10.0.0.3: icmp_seq=1 ttl=64 time=33.5 ms
64 bytes from 10.0.0.3: icmp_seq=2 ttl=64 time=16.0 ms
64 bytes from 10.0.0.3: icmp_seq=3 ttl=64 time=9.69 ms
64 bytes from 10.0.0.3: icmp_seq=4 ttl=64 time=8.61 ms
64 bytes from 10.0.0.3: icmp_seq=5 ttl=64 time=8.57 ms
64 bytes from 10.0.0.3: icmp_seq=6 ttl=64 time=8.64 ms
64 bytes from 10.0.0.3: icmp_seq=7 ttl=64 time=8.74 ms
64 bytes from 10.0.0.3: icmp_seq=8 ttl=64 time=8.49 ms
64 bytes from 10.0.0.3: icmp_seq=9 ttl=64 time=8.58 ms
64 bytes from 10.0.0.3: icmp_seq=10 ttl=64 time=8.80 ms

--- 10.0.0.3 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9015ms
rtt min/avg/max/mdev = 8.486/11.965/33.499/7.506 ms | 9.568 (nilai Avg)

mininet> h2 ping h3 -c 10
PING 10.0.0.3 (10.0.0.3) 56(84) bytes of data.
64 bytes from 10.0.0.3: icmp_seq=1 ttl=64 time=33.1 ms
64 bytes from 10.0.0.3: icmp_seq=2 ttl=64 time=16.0 ms
64 bytes from 10.0.0.3: icmp_seq=3 ttl=64 time=9.20 ms
64 bytes from 10.0.0.3: icmp_seq=4 ttl=64 time=9.13 ms
64 bytes from 10.0.0.3: icmp_seq=5 ttl=64 time=9.21 ms
64 bytes from 10.0.0.3: icmp_seq=6 ttl=64 time=8.73 ms
64 bytes from 10.0.0.3: icmp_seq=7 ttl=64 time=8.53 ms
64 bytes from 10.0.0.3: icmp_seq=8 ttl=64 time=9.18 ms
64 bytes from 10.0.0.3: icmp_seq=9 ttl=64 time=8.50 ms
64 bytes from 10.0.0.3: icmp_seq=10 ttl=64 time=8.92 ms

--- 10.0.0.3 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9014ms
rtt min/avg/max/mdev = 8.503/12.054/33.145/7.344 ms | 9.711 (nilai Avg)
``` 
 > Bentuk Tabel
 
| Kondisi |Src  |Dst |Max |Avg |Mdev|Loss (%)
|--|--|--|--|--|--|-
| Idle | h1 |h4 |37.26|9.7316|8.626|0
| Idle | h2 |h3 |36.06|9.9232|8.3134|0

**1. Nilai Max**

Nilai ini merupakan lama controller mencari jalur dari setiap topologi. Ambil nilai RTT packet pertama dari setiap iterasi lalu hitung rata-rata nya.

**2. Nilai Avg**

Nilai ini merupakan rata-rata RTT ketika topologi sudah terbentuk. Pada setiap iterasi, hitung RTT pada packet ke-2 hingga ke-9. Lalu nilai tersebut dicari rata-rata nya. 

contoh:
- Rata-rata Iterasi 1 = 10.43 ms
- Rata-rata Iterasi 2 = 10.075 ms
- Rata-rata Iterasi 3 = 9.832 ms
- Rata-rata Iterasi 4 = 9.568 ms
- Rata-rata Iterasi 5 = 9.711 ms

$$Avg = \frac{\text{Iterasi 1}+\text{Iterasi 2}+\text{Iterasi 3}+\text{Iterasi 4}+\text{Iterasi 5}}{5}$$

**3. Nilai Mdev**

Nilai rata-rata mdev dari setiap iterasi. Terdapat di bagian bawah setiap melakukan ping
