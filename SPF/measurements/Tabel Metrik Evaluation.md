## Diamond Topology
1. Tabel 1 - Latency (ms)

| Kondisi |Src  |Dst |Min |Avg |Max|Mdev|Loss (%)
|--|--|--|--|--|--|--|-
| Idle |h1  |h3 |0.104|0.376|6.528|1.143|0 
| Idle | h1 |h4 |0.098|0.519|11.148|1.973|0
| Idle | h2 |h3 |0.098|0.248|3.265|0.560|0
| Idle | h2 |h4 |0.077|0.190|1.938|0.330|0
| Loaded| h1 |h3 |0.083|0.125|0.665|0.102|0
| Loaded | h2 |h4 |0.083|0.108|0.205|0.033|0

2. Tabel 2 - Throughput 

| Kondisi |Src  |Dst |Proto|Streams|Throughput|Jitter|Loss (%)
|--|--|--|--|--|--|--|-
| Idle |h1  |h3 |TCP|1|10.7 Gbits/sec|N/A|N/A 
| Idle | h1 |h3 |TCP|2|11.5 Gbits/sec|N/A|N/A
| Idle | h1 |h3 |TCP|4|11.2 Gbits/sec|N/A|N/A
| Idle | h1 |h3 |UDP|1|10.0 Mbits/sec|0.017 ms | 0/12949 (0%)
| Loaded| h1 |h3 |TCP|2|8.04 Gbits/sec|N/A|N/A
| Loaded | h2 |h4 |UDP|1|10.0 Mbits/sec |0.062 ms |0/12949 (0%)
