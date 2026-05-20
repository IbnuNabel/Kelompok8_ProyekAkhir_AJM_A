#!/usr/bin/env python3

import argparse
import heapq
from typing import Dict, List, Tuple, Optional

Graph = Dict[str, Dict[str, int]]


# ============================================================
# 1. Graph Topologi
# ============================================================

def get_topology_graph(topology_name: str) -> Graph:

    topology_name = topology_name.lower()

    if topology_name == "diamond":
        # Sesuai topo-diamond_lab.py:
        # s1-s2-s4 dan s1-s3-s4 adalah dua jalur alternatif equal-cost.
        return {
            "h1": {"s1": 1},
            "h2": {"s1": 1},
            "h3": {"s4": 1},
            "h4": {"s4": 1},

            "s1": {"h1": 1, "h2": 1, "s2": 1, "s3": 1},
            "s2": {"s1": 1, "s4": 1},
            "s3": {"s1": 1, "s4": 1},
            "s4": {"s2": 1, "s3": 1, "h3": 1, "h4": 1},
        }

    if topology_name == "partial_mesh":
        # Sesuai topo-partial_mesh_lab.py:
        # Alternatif utama dari s1 ke s6:
        # 1) s1-s2-s6
        # 2) s1-s3-s6
        # 3) s1-s4-s5-s6
        # Ditambah link s2-s3 dan s3-s5.
        return {
            "h1": {"s1": 1},
            "h2": {"s1": 1},
            "h3": {"s6": 1},
            "h4": {"s6": 1},

            "s1": {"h1": 1, "h2": 1, "s2": 1, "s3": 1, "s4": 1},
            "s2": {"s1": 1, "s6": 1, "s3": 1},
            "s3": {"s1": 1, "s6": 1, "s2": 1, "s5": 1},
            "s4": {"s1": 1, "s5": 1},
            "s5": {"s4": 1, "s6": 1, "s3": 1},
            "s6": {"s2": 1, "s3": 1, "s5": 1, "h3": 1, "h4": 1},
        }

    raise ValueError(
        f"Topologi '{topology_name}' tidak dikenal. "
        "Gunakan: diamond atau partial_mesh."
    )


# ============================================================
# 2. Utility Path
# ============================================================

def reconstruct_path(previous: Dict[str, Optional[str]], source: str, destination: str) -> List[str]:
    
    if destination not in previous:
        return []

    path = []
    current: Optional[str] = destination

    while current is not None:
        path.append(current)
        if current == source:
            break
        current = previous.get(current)

    path.reverse()

    if not path or path[0] != source:
        return []

    return path


def validate_nodes(graph: Graph, source: str, destination: str) -> None:
    
    if source not in graph:
        raise ValueError(f"Node sumber '{source}' tidak ditemukan di graph.")

    if destination not in graph:
        raise ValueError(f"Node tujuan '{destination}' tidak ditemukan di graph.")


# ============================================================
# 3. Algoritma Dijkstra
# ============================================================

def dijkstra(graph: Graph, source: str, destination: str) -> Tuple[List[str], int]:
    
    validate_nodes(graph, source, destination)

    distance = {node: float("inf") for node in graph}
    previous: Dict[str, Optional[str]] = {node: None for node in graph}

    distance[source] = 0
    queue = [(0, source)]

    while queue:
        current_distance, current_node = heapq.heappop(queue)

        if current_node == destination:
            break

        if current_distance > distance[current_node]:
            continue

        for neighbor in sorted(graph[current_node].keys()):
            weight = graph[current_node][neighbor]
            new_distance = current_distance + weight

            if new_distance < distance[neighbor]:
                distance[neighbor] = new_distance
                previous[neighbor] = current_node
                heapq.heappush(queue, (new_distance, neighbor))

    path = reconstruct_path(previous, source, destination)

    if not path:
        raise ValueError(f"Tidak ada jalur dari {source} ke {destination}.")

    return path, int(distance[destination])


# ============================================================
# 4. Algoritma Bellman-Ford
# ============================================================

def bellman_ford(graph: Graph, source: str, destination: str) -> Tuple[List[str], int]:
    
    validate_nodes(graph, source, destination)

    distance = {node: float("inf") for node in graph}
    previous: Dict[str, Optional[str]] = {node: None for node in graph}
    distance[source] = 0

    edges = []
    for node in sorted(graph.keys()):
        for neighbor in sorted(graph[node].keys()):
            edges.append((node, neighbor, graph[node][neighbor]))

    for _ in range(len(graph) - 1):
        updated = False

        for node, neighbor, weight in edges:
            if distance[node] != float("inf") and distance[node] + weight < distance[neighbor]:
                distance[neighbor] = distance[node] + weight
                previous[neighbor] = node
                updated = True

        if not updated:
            break

    for node, neighbor, weight in edges:
        if distance[node] != float("inf") and distance[node] + weight < distance[neighbor]:
            raise ValueError("Graph mengandung negative cycle.")

    path = reconstruct_path(previous, source, destination)

    if not path:
        raise ValueError(f"Tidak ada jalur dari {source} ke {destination}.")

    return path, int(distance[destination])


# ============================================================
# 5. Fungsi Pemilih Algoritma
# ============================================================

def calculate_single_path(
    topology_name: str,
    algorithm_name: str,
    source: str,
    destination: str
) -> Tuple[List[str], int]:
    
    graph = get_topology_graph(topology_name)
    algorithm_name = algorithm_name.lower()

    if algorithm_name == "dijkstra":
        return dijkstra(graph, source, destination)

    if algorithm_name in ["bellman-ford", "bellman_ford", "bellmanford"]:
        return bellman_ford(graph, source, destination)

    raise ValueError(
        f"Algoritma '{algorithm_name}' tidak dikenal. "
        "Gunakan: dijkstra atau bellman-ford."
    )


# ============================================================
# 6. CLI untuk Testing
# ============================================================

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Single-path SPF checker untuk topologi Diamond dan Partial Mesh."
    )

    parser.add_argument(
        "--topology",
        choices=["diamond", "partial_mesh"],
        default="diamond",
        help="Pilih topologi yang akan diuji."
    )

    parser.add_argument(
        "--algorithm",
        choices=["dijkstra", "bellman-ford"],
        default="dijkstra",
        help="Pilih algoritma single-path."
    )

    parser.add_argument(
        "--src",
        default="h1",
        help="Node sumber, contoh: h1."
    )

    parser.add_argument(
        "--dst",
        default="h4",
        help="Node tujuan, contoh: h4."
    )

    args = parser.parse_args()

    path, total_cost = calculate_single_path(
        topology_name=args.topology,
        algorithm_name=args.algorithm,
        source=args.src,
        destination=args.dst,
    )

    print("=== Single-Path SPF Result ===")
    print(f"Topologi  : {args.topology}")
    print(f"Algoritma : {args.algorithm}")
    print(f"Source    : {args.src}")
    print(f"Dest      : {args.dst}")
    print(f"Cost      : {total_cost}")
    print(f"Path      : {' -> '.join(path)}")


if __name__ == "__main__":
    main()

