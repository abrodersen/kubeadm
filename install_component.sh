#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo -e "this script must be run as root"
    exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source $SCRIPT_DIR/versions.sh

case "$(uname -m)" in
    aarch64)
        ARCH="arm64"
        ;;
    x86_64)
        ARCH="amd64"
        ;;
esac

for component in "$@"; do
    case "$component" in
        kubeadm)
            echo "installing kubeadm ${KUBEADM_VERSION}"
            curl -sSLf -o /usr/local/bin/kubeadm https://storage.googleapis.com/kubernetes-release/release/${KUBEADM_VERSION}/bin/linux/$ARCH/kubeadm
            chmod +x /usr/local/bin/kubeadm
            ;;
        kubelet)
            echo "installing kubelet ${KUBELET_VERSION}"
            curl -sSLf -o /usr/local/bin/kubelet https://storage.googleapis.com/kubernetes-release/release/${KUBELET_VERSION}/bin/linux/$ARCH/kubelet
            chmod +x /usr/local/bin/kubelet
            ;;
        kubectl)
            echo "installing kubectl ${KUBECTL_VERSION}"
            curl -sSLf -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/$ARCH/kubectl
            chmod +x /usr/local/bin/kubectl
            ;;
        release)
            echo "installing kubelet unit file ${KUBERNETES_RELEASE_VERSION}"
            curl -sSLf "https://raw.githubusercontent.com/kubernetes/release/${KUBERNETES_RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sed "s:/usr/bin:/usr/local/bin:g" > /etc/systemd/system/kubelet.service

            echo "installing kubeadm unit override file ${KUBERNETES_RELEASE_VERSION}"
            mkdir -p /etc/systemd/system/kubelet.service.d
            curl -sSLf "https://raw.githubusercontent.com/kubernetes/release/${KUBERNETES_RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:/usr/local/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
        
            echo "reloading daemon configs"
	        systemctl daemon-reload
            ;;
    esac
done
