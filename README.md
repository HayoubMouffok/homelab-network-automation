# Homelab réseau – OSPF / BGP automatisé (containerlab + Ansible + CI)

Lab réseau reproductible qui simule un petit opérateur : **deux systèmes autonomes**, du **routage interne OSPF**, de l'**iBGP/eBGP** entre AS, des configurations **générées par Ansible** et des **tests automatiques** exécutés à chaque push par GitHub Actions.

## Topologie

```
 h1 (192.168.1.10)                                   h2 (192.168.3.10)
   |                                                   |
 [r1] ---- OSPF area 0 / iBGP ---- [r2] ---- eBGP ---- [r3]
 1.1.1.1    10.0.12.0/30          2.2.2.2  10.0.23.0/30  3.3.3.3
 \__________ AS 65001 __________________/              AS 65002
```

- **r1, r2** (AS 65001) : OSPF sur les loopbacks et le lien interne, session iBGP entre loopbacks (`update-source lo`, `next-hop-self` sur r2).
- **r3** (AS 65002) : session eBGP avec r2.
- **h1, h2** : hôtes Linux, chacun derrière un AS différent.

## Stack

containerlab, FRRouting 9.1, Ansible (templates Jinja2), Docker, Bash, GitHub Actions, Make.

## Utilisation

```bash
make configs   # Ansible génère configs/<routeur>/frr.conf depuis ansible/inventory.yml
make deploy    # containerlab déploie les 5 nœuds
make test      # vérifie l'adjacence OSPF, la route BGP et le ping h1 -> h2
make destroy
```

## Tests automatiques

`tests/verify.sh` échoue si l'un de ces points n'est pas vérifié :

1. adjacence OSPF r1–r2 à l'état **Full** ;
2. préfixe `192.168.3.0/24` appris en BGP et sélectionné sur r1 ;
3. connectivité de bout en bout **h1 → h2**.

Le workflow `.github/workflows/lab.yml` rejoue tout le scénario (génération, déploiement, tests) à chaque push.

## Pistes d'évolution

Supervision Prometheus/Grafana des sessions BGP, filtrage par route-maps, ajout de VLAN et d'un pare-feu entre les AS.
