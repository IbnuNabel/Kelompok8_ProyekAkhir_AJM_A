#!/usr/bin/env python3
"""Diamond topology lab for single-path vs multipath SPF comparison.

Topology purpose:
- Provide exactly 2 equal-cost alternative paths.
- Suitable baseline to compare:
  1) single-path (Dijkstra/Bellman-Ford)
  2) multipath (ECMP / hash-based distribution)

Layout:

    h1,h2 -- s1 --+-- s2 --+
                   \       |
                    +-- s3--+-- s4 -- h3,h4

Equal-cost paths from s1 to s4:
- Path A: s1 -> s2 -> s4
- Path B: s1 -> s3 -> s4
"""

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import RemoteController
from mininet.link import TCLink
from mininet.log import setLogLevel, info
from mininet.cli import CLI


class DiamondTopo(Topo):
    """4-switch diamond topology with 2 equal-cost paths."""

    def addSwitch(self, name, **opts):
        kwargs = {"protocols": "OpenFlow13"}
        kwargs.update(opts)
        return super(DiamondTopo, self).addSwitch(name, **kwargs)

    def __init__(self):
        Topo.__init__(self)

        info("*** Add Hosts\n")
        # Use a common /8 to keep host reachability at L2 (no router required).
        h1 = self.addHost("h1", ip="10.0.0.1/8")
        h2 = self.addHost("h2", ip="10.0.0.2/8")
        h3 = self.addHost("h3", ip="10.0.0.3/8")
        h4 = self.addHost("h4", ip="10.0.0.4/8")

        info("*** Add Switches\n")
        s1 = self.addSwitch("s1")
        s2 = self.addSwitch("s2")
        s3 = self.addSwitch("s3")
        s4 = self.addSwitch("s4")

        info("*** Add Host Links\n")
        self.addLink(s1, h1, port1=1, port2=1)
        self.addLink(s1, h2, port1=2, port2=1)
        self.addLink(s4, h3, port1=1, port2=1)
        self.addLink(s4, h4, port1=2, port2=1)

        info("*** Add Switch Links (equal cost)\n")
        # Path A: s1 -> s2 -> s4
        self.addLink(s1, s2, port1=3, port2=1, bw=100, delay="2ms", use_hfsc=True)
        self.addLink(s2, s4, port1=2, port2=3, bw=100, delay="2ms", use_hfsc=True)

        # Path B: s1 -> s3 -> s4
        self.addLink(s1, s3, port1=4, port2=1, bw=100, delay="2ms", use_hfsc=True)
        self.addLink(s3, s4, port1=2, port2=4, bw=100, delay="2ms", use_hfsc=True)


def run():
    topo = DiamondTopo()
    net = Mininet(
        topo=topo,
        controller=RemoteController,
        link=TCLink,
        autoSetMacs=True,
        autoStaticArp=True,
        waitConnected=True,
    )

    info("\n*** Disable IPv6\n")
    for host in net.hosts:
        host.cmd("sysctl -w net.ipv6.conf.all.disable_ipv6=1")
    for sw in net.switches:
        sw.cmd("sysctl -w net.ipv6.conf.all.disable_ipv6=1")

    net.start()
    info("\n*** Diamond topology ready\n")
    info("*** Suggested tests: h1 ping h4, iperf between h1 and h4\n")
    CLI(net)
    net.stop()


if __name__ == "__main__":
    setLogLevel("info")
    run()
