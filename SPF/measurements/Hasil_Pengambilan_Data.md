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

## Partial Mesh Topology
### Djikstra Multipath
1. Tabel 1 - Latency (ms)

| Kondisi |Src  |Dst |Max |Avg |Mdev|Loss (%)
|--|--|--|--|--|--|-
| Idle | h1 |h4 ||||0
| Idle | h2 |h3 ||||0

2. Tabel 2 - Throughput 

| Kondisi |Src  |Dst |Proto|Streams|Throughput|Jitter|Loss (%)
|--|--|--|--|--|--|--|-
| Idle |h1  |h3 |TCP|1|95.5 Mbits/sec|N/A|N/A 
| Idle | h1 |h3 |TCP|2|95.5 Mbits/sec  |N/A|N/A
| Idle | h1 |h3 |TCP|4|191 Mbits/sec |N/A|N/A
| Idle | h1 |h3 |UDP|1|9.99 Mbits/sec|0.028 ms| 0/12949 (0%)

3. Tabel 3 - Load Balancing 

| Switch|Port  |Jalur|Tx Bytes BEFORE|Tx Bytes After |Delta (bytes)|Delta (MB)|Loss (%)
|--|--|--|--|--|--|--|-
| s1| Port 3|Jalur A |1466|21928672|21927206|21,9|52.678
| s1 | Port 4 |Jalur B |1330|19696880|19695550|19,6|47.316
| s1 | Port 5 |Jalur C |1134|3834|2700|0.0027|0.006

### Bellman
1. Tabel 1 - Latency (ms)

| Kondisi |Src  |Dst |Max |Avg |Mdev|Loss (%)
|--|--|--|--|--|--|-
| Idle | h1 |h4 ||||0
| Idle | h2 |h3 ||||0

2. Tabel 2 - Throughput 

| Kondisi |Src  |Dst |Proto|Streams|Throughput|Jitter|Loss (%)
|--|--|--|--|--|--|--|-
| Idle |h1  |h3 |TCP|1|95.4 Mbits/sec|N/A|N/A 
| Idle | h1 |h3 |TCP|2|95.5 Mbits/sec |N/A|N/A
| Idle | h1 |h3 |TCP|4|191 Mbits/sec|N/A|N/A
| Idle | h1 |h3 |UDP|1|9.99 Mbits/sec |0.067 ms| 0/12949 (0%)

3. Tabel 3 - Load Balancing 

| Switch|Port  |Jalur|Tx Bytes BEFORE|Tx Bytes After |Delta (bytes)|Delta (MB)|Loss (%)
|--|--|--|--|--|--|--|-
| s1| Port 3|Jalur A |1526|29936327|29934801|29,9|53.266
| s1 | Port 4 |Jalur B |1330|26261881|26260551|26,6|46.728
| s1 | Port 5 |Jalur C |1134|4614|3480|0,0034|0.006

### Suurballe
1. Tabel 1 - Latency (ms)

| Kondisi |Src  |Dst |Max |Avg |Mdev|Loss (%)
|--|--|--|--|--|--|-
| Idle | h1 |h4 |28.36|9.476|6.079|0
| Idle | h2 |h3 |29.82|9.218|6.47|0

2. Tabel 2 - Throughput 

| Kondisi |Src  |Dst |Proto|Streams|Throughput|Jitter|Loss (%)
|--|--|--|--|--|--|--|-
| Idle |h1  |h3 |TCP|1|95.3 Mbits/sec|N/A|N/A 
| Idle | h1 |h3 |TCP|2|95.5 Mbits/sec|N/A|N/A
| Idle | h1 |h3 |TCP|4|190 Mbits/sec|N/A|N/A
| Idle | h1 |h3 |UDP|1|9.99 Mbits/sec|0.041 ms| 0/12949

3. Tabel 3 - Load Balancing 

| Switch|Port  |Jalur|Tx Bytes BEFORE|Tx Bytes After |Delta (bytes)|Delta (MB)|Loss (%)
|--|--|--|--|--|--|--|-
| s1| Port 3|Jalur A |1074|194653706|194652632|29,9|66.595
| s1 | Port 4 |Jalur B |1112|97639904|97638792|33.4043
| s1 | Port 5 |Jalur C |1564|3894|2330|0,0034|0.0007
