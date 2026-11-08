#!/usr/bin/env bash
# Vérifie OSPF, BGP et la connectivité de bout en bout h1 -> h2
set -euo pipefail
ex() { docker exec "clab-homelab-$1" "${@:2}"; }

echo "Attente de la convergence BGP..."
for _ in $(seq 1 40); do
  ex r1 vtysh -c "show ip bgp 192.168.3.0/24" 2>/dev/null | grep -q "best" && break
  sleep 3
done

ex r2 vtysh -c "show ip ospf neighbor"
ex r2 vtysh -c "show bgp summary"
ex r1 vtysh -c "show ip route"

ex r2 vtysh -c "show ip ospf neighbor" | grep -q "Full"   || { echo "ECHEC : adjacence OSPF"; exit 1; }
ex r1 vtysh -c "show ip bgp 192.168.3.0/24" | grep -q "best" || { echo "ECHEC : route BGP"; exit 1; }
ex h1 ping -c 3 -W 2 192.168.3.10 || { echo "ECHEC : ping h1 -> h2"; exit 1; }
echo "OK : OSPF Full, BGP établi, h1 joint h2"
