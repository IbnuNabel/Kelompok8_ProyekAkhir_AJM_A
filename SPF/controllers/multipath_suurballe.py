import os
import sys
import eventlet
eventlet.monkey_patch()

# Add parent directory (SPF) to sys.path so we can import 'algorithms'
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
if parent_dir not in sys.path:
    sys.path.insert(0, parent_dir)

# pyrefly: ignore [missing-import]
from os_ken.controller import ofp_event
from os_ken.controller.handler import MAIN_DISPATCHER, set_ev_cls
from os_ken.lib.packet import ethernet, ether_types, packet

# Impor base controller yang sudah kita modifikasi
from base_controller import SPFBaseController

# Impor algoritma Suurballe
from algorithms.suurballe import suurballe_edge_disjoint


class MultipathSuurballeController(SPFBaseController):
    """Controller Multipath dengan algoritma Suurballe untuk mencari 2 edge-disjoint paths."""
    
    FLOW_COOKIE = 0x5350460000000003
    MAX_PATHS = 2

    def __init__(self, *args, **kwargs):
        super(MultipathSuurballeController, self).__init__(*args, **kwargs)
        self.path_cache = {}
        self.flow_groups = {}

    def compute_multipath(self, src, dst, first_port, final_port):
        """Mencari maksimal 2 jalur edge-disjoint terpendek menggunakan Suurballe."""
        if src not in self.switches or dst not in self.switches:
            return []
        if src == dst:
            return [[(src, first_port, final_port)]]

        # Cek apakah sudah pernah dihitung sebelumnya
        cache_key = (src, dst, first_port, final_port)
        if cache_key in self.path_cache:
            return self.path_cache[cache_key]

        # Memanggil algoritma Suurballe dari modul algorithms
        valid_node_paths = suurballe_edge_disjoint(self.adjacency, src, dst)
        
        # Anotasi (dpid, in_port, out_port)
        decorated_paths = []
        for n_path in valid_node_paths:
            dec = []
            in_port = first_port
            valid = True
            for s1, s2 in zip(n_path[:-1], n_path[1:]):
                out_port = self._get_port(s1, s2)
                if out_port is None:
                    valid = False
                    break
                dec.append((s1, in_port, out_port))
                in_port = self._get_port(s2, s1)
            
            if valid:
                dec.append((n_path[-1], in_port, final_port))
                decorated_paths.append(dec)
                
        self.path_cache[cache_key] = decorated_paths
        self.logger.info("[MP-COMPUTE-SUURBALLE] %s->%s found %d path(s)", src, dst, len(decorated_paths))
        return decorated_paths

    def install_multipath(self, paths, src_mac, dst_mac, weights=None):
        """Menginstalasi Select Group di Ingress dan Unicast flows di Transit."""
        if not paths:
            return

        key = (src_mac, dst_mac)
        if self.installed_paths.get(key) == paths:
            return

        ingress_dpid = paths[0][0][0]
        ingress_in_port = paths[0][0][1]
        
        # Ambil semua out_port unik di ingress switch
        ingress_out_ports = sorted(list(set([p[0][2] for p in paths if p and p[0][0] == ingress_dpid])))

        ingress_dp = self.datapaths.get(ingress_dpid)
        if not ingress_dp:
            return

        # 1. Install aliran unicast di switch transit & egress
        for path in paths:
            for sw, in_p, out_p in path[1:]:
                dp = self.datapaths.get(sw)
                if dp:
                    self._install_unicast_flow(dp, in_p, out_p, src_mac, dst_mac)

        # 2. Install SELECT Group di ingress switch
        group_id = self._alloc_group_id(src_mac, dst_mac)
        
        # Panggil fungsi dari base_controller
        if self._install_select_group(ingress_dp, group_id, ingress_out_ports, weights=weights):
            self.flow_groups[key] = (ingress_dpid, group_id)
            self._install_group_flow(ingress_dp, ingress_in_port, src_mac, dst_mac, group_id)
            self.installed_paths[key] = paths
            self.logger.info("[MP-INSTALL-SUURBALLE] %s->%s paths=%d group=%d weights=%s", 
                             src_mac, dst_mac, len(paths), group_id, weights)

    # ---------------------------------------------------------
    # Base Overrides
    # ---------------------------------------------------------
    
    def compute_path(self, src, dst, first_port, final_port):
        """Diperlukan oleh abstract class base_controller, kembalikan 1 jalur saja (fallback)."""
        paths = self.compute_multipath(src, dst, first_port, final_port)
        return paths[0] if paths else []

    def _flush_all_flows(self):
        for dp in self.datapaths.values():
            self._delete_all_flows(dp)
            # Hapus semua grup
            parser = dp.ofproto_parser
            ofproto = dp.ofproto
            dp.send_msg(parser.OFPGroupMod(
                datapath=dp, command=ofproto.OFPGC_DELETE,
                type_=ofproto.OFPGT_SELECT, group_id=ofproto.OFPG_ALL, buckets=[]
            ))
        self.installed_paths.clear()
        self.path_cache.clear()
        self.flow_groups.clear()

    def _reinstall_all_known_routes(self):
        hosts = self._active_hosts()
        for src_mac in hosts:
            for dst_mac in hosts:
                if src_mac == dst_mac:
                    continue
                src_loc = self.mymacs.get(src_mac)
                dst_loc = self.mymacs.get(dst_mac)
                if not src_loc or not dst_loc:
                    continue
                
                paths = self.compute_multipath(src_loc[0], dst_loc[0], src_loc[1], dst_loc[1])
                if paths:
                    # Untuk eksperimen, jika terdapat tepat 2 jalur, gunakan weight 70:30
                    custom_weights = [7, 3] if len(paths) == 2 else None
                    self.install_multipath(paths, src_mac, dst_mac, weights=custom_weights)

    @set_ev_cls(ofp_event.EventOFPPacketIn, MAIN_DISPATCHER)
    def _packet_in_handler(self, ev):
        """Override packet_in untuk mendukung grup multipath."""
        msg = ev.msg
        dp = msg.datapath
        ofproto = dp.ofproto
        parser = dp.ofproto_parser
        in_port = msg.match["in_port"]
        pkt = packet.Packet(msg.data)
        eth = pkt.get_protocol(ethernet.ethernet)

        if eth.ethertype == ether_types.ETH_TYPE_LLDP:
            return

        src, dst, dpid = eth.src, eth.dst, dp.id

        if self._is_access_port(dpid, in_port):
            self._update_host_location(src, dpid, in_port)

        if src not in self.mymacs:
            return

        if dst in self.mymacs:
            key = (src, dst)
            if key in self.installed_paths:
                paths = self.installed_paths[key]
            else:
                src_sw, src_port = self.mymacs[src]
                dst_sw, dst_port = self.mymacs[dst]
                paths = self.compute_multipath(src_sw, dst_sw, src_port, dst_port)
                if paths:
                    # Modifikasi bobot (Topik 2) bisa disesuaikan di sini.
                    # Jika ada 2 jalur, buat asimetris [7, 3]. Jika selain itu, biarkan merata (None).
                    custom_weights = [7, 3] if len(paths) == 2 else None
                    self.install_multipath(paths, src, dst, weights=custom_weights)
                else:
                    return

            # Teruskan paket yang tertahan
            group_info = self.flow_groups.get(key)
            if group_info and group_info[0] == dpid:
                # Ingress switch: Gunakan ActionOutput langsung untuk paket pertama
                # untuk menghindari race condition dimana GroupMod belum selesai diproses switch.
                first_out_port = paths[0][0][2]
                actions = [parser.OFPActionOutput(first_out_port)]
            else:
                # Transit switch: cari port keluaran di semua jalur yang cocok dengan in_port
                out_port = None
                for path in paths:
                    for sw, in_p, out_p in path:
                        if sw == dpid and in_p == in_port:
                            out_port = out_p
                            break
                    if out_port:
                        break
                
                if out_port:
                    actions = [parser.OFPActionOutput(out_port)]
                else:
                    return

            data = msg.data if msg.buffer_id == ofproto.OFP_NO_BUFFER else None
            dp.send_msg(parser.OFPPacketOut(
                datapath=dp, buffer_id=msg.buffer_id,
                in_port=in_port, actions=actions, data=data
            ))
        else:
            self._flood_over_tree(dp, in_port, msg.data, msg.buffer_id)

if __name__ == '__main__':
    current_file = os.path.abspath(__file__)
    sys.path.insert(0, os.path.dirname(current_file))
    
    # Aplikasi yang wajib dijalankan: controller kita dan modul pencarian topologi
    apps_to_load = ['multipath_suurballe', 'os_ken.topology.switches']
    
    try:
        from os_ken.cmd.manager import main
        # Cara lama: panggil osken-manager dan teruskan argumen
        sys.argv = ['osken-manager', '--observe-links'] + apps_to_load
        sys.exit(main())
    except ImportError:
        # Pendekatan baru untuk os-ken >= 4.2.0
        from os_ken import cfg
        from os_ken.base.app_manager import AppManager
        
        app_mgr = AppManager.get_instance()
        
        # Harus di-load SEBELUM cfg.CONF agar modul bisa register opsi CLI-nya
        app_mgr.load_apps(apps_to_load)
        
        # Panggil cfg.CONF dan berikan flag '--observe-links' secara internal
        cfg.CONF(project='os_ken', args=['--observe-links'])
        
        contexts = app_mgr.create_contexts()
        services = []
        services.extend(app_mgr.instantiate_apps(**contexts))
        
        try:
            from os_ken.lib import hub
            hub.joinall(services)
        except Exception:
            pass
        sys.exit(0)
