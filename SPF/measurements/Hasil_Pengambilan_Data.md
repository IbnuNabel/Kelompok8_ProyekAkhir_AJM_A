## Diamond Topology
### Djikstra Multipath
1. Tabel 1 - Latency (ms)

| Kondisi |Src  |Dst |Max |Avg |Mdev|Loss (%)
|--|--|--|--|--|--|-
| Idle | h1 |h4 |26.72|8.8492|5.5432|0
| Idle | h2 |h3 |33.7|9.3974|7.5962|0

2. Tabel 2 - Throughput 

| Kondisi |Src  |Dst |Proto|Streams|Throughput|Jitter|Loss (%)
|--|--|--|--|--|--|--|-
| Idle |h1  |h3 |TCP|1|95.2 Mbits/sec|N/A|N/A 
| Idle | h1 |h3 |TCP|2|95.5 Mbits/sec|N/A|N/A
| Idle | h1 |h3 |TCP|4|94.8 Mbits/sec|N/A|N/A
| Idle | h1 |h3 |UDP|1|9.99 Mbits/sec|0.030 ms| 0/12949 (0%)

3. Tabel 3 - Load Balancing 

| Switch|Port  |Jalur|Tx Bytes BEFORE|Tx Bytes After |Delta (bytes)|Delta (MB)|Loss (%)
|--|--|--|--|--|--|--|-
| s1| Port 3|Jalur A |4046|37691837|37687791|37,6|50.001
| s1 | Port 4 |Jalur B |3850|37689161|37685311|37,6|49.999

### Bellman
1. Tabel 1 - Latency (ms)

| Kondisi |Src  |Dst |Max |Avg |Mdev|Loss (%)
|--|--|--|--|--|--|-
| Idle | h1 |h4 |52.04|9.6676|12.9204|0
| Idle | h2 |h3 |37.42|9.8778|8.7308|0

2. Tabel 2 - Throughput 

| Kondisi |Src  |Dst |Proto|Streams|Throughput|Jitter|Loss (%)
|--|--|--|--|--|--|--|-
| Idle |h1  |h3 |TCP|1|95.4 Mbits/sec|N/A|N/A 
| Idle | h1 |h3 |TCP|2|191 Mbits/sec|N/A|N/A
| Idle | h1 |h3 |TCP|4| 95.3 Mbits/sec|N/A|N/A
| Idle | h1 |h3 |UDP|1|9.99 Mbits/sec |0.131 ms| 0/12949 (0%)

3. Tabel 3 - Load Balancing 

| Switch|Port  |Jalur|Tx Bytes BEFORE|Tx Bytes After |Delta (bytes)|Delta (MB)|Loss (%)
|--|--|--|--|--|--|--|-
| s1| Port 3|Jalur A |1586|29547385|29545799|29,5|53.3
| s1 | Port 4 |Jalur B |1390|25870121|25868731|25,8|46.6

### Suurballe
1. Tabel 1 - Latency (ms)

| Kondisi |Src  |Dst |Max |Avg |Mdev|Loss (%)
|--|--|--|--|--|--|-
| Idle | h1 |h4 |37.26|9.7316|8.626|0
| Idle | h2 |h3 |36.06|9.9232|8.3134|0

2. Tabel 2 - Throughput 

| Kondisi |Src  |Dst |Proto|Streams|Throughput|Jitter|Loss (%)
|--|--|--|--|--|--|--|-
| Idle |h1  |h3 |TCP|1|95.5 Mbits/sec|N/A|N/A 
| Idle | h1 |h3 |TCP|2|95.5 Mbits/sec|N/A|N/A
| Idle | h1 |h3 |TCP|4|191 Mbits/sec|N/A|N/A
| Idle | h1 |h3 |UDP|1|9.99 Mbits/sec|0.113 ms| 0/12949

3. Tabel 3 - Load Balancing 

| Switch|Port  |Jalur|Tx Bytes BEFORE|Tx Bytes After |Delta (bytes)|Delta (MB)|Loss (%)
|--|--|--|--|--|--|--|-
| s1| Port 3|Jalur A |1668|26789169|26787501|26,7|46.7
| s1 | Port 4 |Jalur B |1336|30462697|30461361|30,4|53.2
