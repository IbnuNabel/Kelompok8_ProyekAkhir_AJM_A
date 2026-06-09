import matplotlib.pyplot as plt
import numpy as np

# ── Data ──────────────────────────────────────────────────────────────────────

labels = ['Dijkstra', 'Bellman-Ford', 'Suurballe']

# Load Balancing Diamond
diamond_A = [50.001, 53.3, 46.7]
diamond_B = [49.999, 46.6, 53.2]

# Load Balancing Partial Mesh
mesh_A = [52.678, 53.266, 66.595]
mesh_B = [47.316, 46.728, 33.404]
mesh_C = [0.006,  0.006,  0.0006]

# Throughput Diamond
diamond_tp = {
    'Dijkstra':     [95.2, 95.5, 94.8],
    'Bellman-Ford': [95.4, 191,  95.3],
    'Suurballe':    [95.5, 95.5, 191 ],
}

# Throughput Partial Mesh
mesh_tp = {
    'Dijkstra':     [95.5, 95.5, 191],
    'Bellman-Ford': [95.4, 95.5, 191],
    'Suurballe':    [95.3, 95.5, 190],
}

stream_labels = ['1 Stream', '2 Stream', '4 Stream']

# Latensi Max Diamond
latency_diamond_max = {
    'h1→h4': [26.72, 52.04, 37.26],
    'h2→h3': [33.7,  37.42, 36.06],
}

# Latensi Max Partial Mesh
latency_mesh_max = {
    'h1→h4': [32.2,  32.1,  28.36],
    'h2→h3': [29.9,  35.5,  29.82],
}

# ── Warna ─────────────────────────────────────────────────────────────────────

colors      = ['#378ADD', '#1D9E75', '#D85A30']
edge_colors = ['#185FA5', '#0F6E56', '#993C1D']
path_colors = {
    'A': ('#378ADD', '#185FA5'),
    'B': ('#1D9E75', '#0F6E56'),
    'C': ('#D85A30', '#993C1D'),
}

# ══════════════════════════════════════════════════════════════════════════════
# GRAFIK 1 — Load Balancing Diamond & Partial Mesh
# ══════════════════════════════════════════════════════════════════════════════

x     = np.arange(len(labels))
width = 0.35

fig1, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
fig1.suptitle('Distribusi Load-Balancing per Algoritme', fontsize=14, fontweight='bold')

# ── Diamond ───────────────────────────────────────────────────────────────────
b1 = ax1.bar(x - width/2, diamond_A, width,
             label='Jalur A (s1→s2)', color=path_colors['A'][0],
             edgecolor=path_colors['A'][1], linewidth=0.8)
b2 = ax1.bar(x + width/2, diamond_B, width,
             label='Jalur B (s1→s3)', color=path_colors['B'][0],
             edgecolor=path_colors['B'][1], linewidth=0.8)

for bar in b1:
    ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
             f'{bar.get_height():.1f}%', ha='center', va='bottom', fontsize=9)
for bar in b2:
    ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
             f'{bar.get_height():.1f}%', ha='center', va='bottom', fontsize=9)

ax1.axhline(y=50, color='gray', linestyle='--', linewidth=0.8,
            alpha=0.6, label='50% (ideal)')
ax1.set_title('Topologi Diamond', fontsize=12)
ax1.set_ylabel('Persentase Beban (%)')
ax1.set_ylim(0, 65)
ax1.set_xticks(x)
ax1.set_xticklabels(labels)
ax1.legend(fontsize=9)
ax1.grid(axis='y', alpha=0.3)
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)

# ── Partial Mesh ──────────────────────────────────────────────────────────────
w = 0.25
b3 = ax2.bar(x - w, mesh_A, w,
             label='Jalur A (s1→s2→s6)', color=path_colors['A'][0],
             edgecolor=path_colors['A'][1], linewidth=0.8)
b4 = ax2.bar(x,     mesh_B, w,
             label='Jalur B (s1→s3→s6)', color=path_colors['B'][0],
             edgecolor=path_colors['B'][1], linewidth=0.8)
b5 = ax2.bar(x + w, mesh_C, w,
             label='Jalur C (s1→s4→s5→s6)', color=path_colors['C'][0],
             edgecolor=path_colors['C'][1], linewidth=0.8)

for bar in b3:
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
             f'{bar.get_height():.1f}%', ha='center', va='bottom', fontsize=9)
for bar in b4:
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
             f'{bar.get_height():.1f}%', ha='center', va='bottom', fontsize=9)
for bar in b5:
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
             '~0%', ha='center', va='bottom', fontsize=9)

ax2.axhline(y=50, color='gray', linestyle='--', linewidth=0.8,
            alpha=0.6, label='50% (ideal)')
ax2.set_title('Topologi Partial Mesh', fontsize=12)
ax2.set_ylabel('Persentase Beban (%)')
ax2.set_ylim(0, 80)
ax2.set_xticks(x)
ax2.set_xticklabels(labels)
ax2.legend(fontsize=9)
ax2.grid(axis='y', alpha=0.3)
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)

plt.tight_layout()
plt.savefig('grafik1_load_balancing.png', dpi=150, bbox_inches='tight')
plt.show()

# ══════════════════════════════════════════════════════════════════════════════
# GRAFIK 2 — Throughput TCP per Jumlah Stream
# ══════════════════════════════════════════════════════════════════════════════

x2    = np.arange(len(stream_labels))
width = 0.25

fig2, (ax3, ax4) = plt.subplots(1, 2, figsize=(13, 5))
fig2.suptitle('Throughput TCP per Jumlah Stream per Algoritme',
              fontsize=14, fontweight='bold')

def draw_throughput(ax, data, title):
    for i, (algo, color, ec) in enumerate(zip(labels, colors, edge_colors)):
        offset = (i - 1) * width
        bars = ax.bar(x2 + offset, data[algo], width,
                      label=algo, color=color,
                      edgecolor=ec, linewidth=0.8)
        for bar in bars:
            val = bar.get_height()
            marker = '*' if val >= 185 else ''
            ax.text(bar.get_x() + bar.get_width()/2,
                    val + 2,
                    f'{val:.0f}{marker}',
                    ha='center', va='bottom', fontsize=8.5,
                    fontweight='bold' if marker else 'normal',
                    color='#D85A30' if marker else 'black')

    ax.axhline(y=95,  color='gray',    linestyle='--',
               linewidth=0.8, alpha=0.5, label='~95 Mbps (1 jalur)')
    ax.axhline(y=191, color='#D85A30', linestyle=':',
               linewidth=1,   alpha=0.7, label='~191 Mbps (multipath aktif)')
    ax.set_title(title, fontsize=12)
    ax.set_ylabel('Throughput (Mbits/sec)')
    ax.set_ylim(0, 230)
    ax.set_xticks(x2)
    ax.set_xticklabels(stream_labels)
    ax.legend(fontsize=8.5)
    ax.grid(axis='y', alpha=0.3)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.text(0.99, 0.97, '* multipath aktif',
            transform=ax.transAxes, fontsize=8,
            color='#D85A30', ha='right', va='top', style='italic')

draw_throughput(ax3, diamond_tp, 'Topologi Diamond')
draw_throughput(ax4, mesh_tp,    'Topologi Partial Mesh')

plt.tight_layout()
plt.savefig('grafik2_throughput.png', dpi=150, bbox_inches='tight')
plt.show()

# ══════════════════════════════════════════════════════════════════════════════
# GRAFIK 3 — Latensi Max per Algoritme
# ══════════════════════════════════════════════════════════════════════════════

x3    = np.arange(len(labels))
width = 0.35

fig3, (ax5, ax6) = plt.subplots(1, 2, figsize=(13, 5))
fig3.suptitle('Latensi Maksimum per Algoritme',
              fontsize=14, fontweight='bold')

def draw_latency(ax, data, title):
    paths = list(data.keys())
    w = 0.35
    offsets = [-w/2, w/2]
    path_c = [('#378ADD', '#185FA5'), ('#D85A30', '#993C1D')]

    for i, (path, (c, ec)) in enumerate(zip(paths, path_c)):
        bars = ax.bar(x3 + offsets[i], data[path], w,
                      label=path, color=c,
                      edgecolor=ec, linewidth=0.8)
        for bar in bars:
            ax.text(bar.get_x() + bar.get_width()/2,
                    bar.get_height() + 0.3,
                    f'{bar.get_height():.1f}',
                    ha='center', va='bottom', fontsize=9)

    ax.set_title(title, fontsize=12)
    ax.set_ylabel('Latency Max (ms)')
    ax.set_ylim(0, 65)
    ax.set_xticks(x3)
    ax.set_xticklabels(labels)
    ax.legend(fontsize=9)
    ax.grid(axis='y', alpha=0.3)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

draw_latency(ax5, latency_diamond_max, 'Topologi Diamond')
draw_latency(ax6, latency_mesh_max,    'Topologi Partial Mesh')

plt.tight_layout()
plt.savefig('grafik3_latensi.png', dpi=150, bbox_inches='tight')
plt.show()
