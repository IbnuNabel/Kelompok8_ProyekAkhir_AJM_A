"""Pure-Python graph algorithm implementations for SDN path computation.

Each module provides a standalone, testable function that operates on
adjacency lists and returns results suitable for path reconstruction.

All functions accept:
    adjacency  - dict mapping switch_id -> [(neighbor_id, out_port), ...]
    weights    - optional dict mapping (src_id, dst_id) -> cost  (default 1)

Modules and their complexities:
    dijkstra       - Dijkstra's algorithm           O((V+E) log V)
    bellman_ford   - Bellman-Ford                   O(V * E)
    suurballe      - Edge-disjoint shortest paths   O((V+E) log V)
"""

from .dijkstra import dijkstra, dijkstra_multi_parent
from .bellman_ford import bellman_ford
from .suurballe import suurballe_edge_disjoint

__all__ = [
    "dijkstra",
    "dijkstra_multi_parent",
    "bellman_ford",
    "suurballe_edge_disjoint",
]
