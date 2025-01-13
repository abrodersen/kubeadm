#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo -e "this script must be run as root"
    exit 1
fi

cat > /etc/modules-load.d/30-kubelet.conf <<EOF
br_netfilter
EOF

cat > /etc/modules-load.d/30-kube-proxy.conf <<EOF
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
ip_vs_sed
nf_conntrack
EOF

cat > /etc/modules-load.d/30-kube-router.conf <<EOF
ip_set
EOF

systemctl restart systemd-modules-load.service

cat > /etc/sysctl.d/30-kubelet.conf <<EOF
net.ipv4.ip_forward=1
EOF

sysctl --load /etc/sysctl.d/30-kubelet.conf