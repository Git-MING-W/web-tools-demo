#!/bin/bash

LOG_FILE="/var/log/iptables-setup.log"

log() {
    echo "$(date '+%F %T') $1" | tee -a "$LOG_FILE"
}

# 自動抓第二張網卡 IP，沒有就抓第一張
get_network_ip() {
    local ip_list=($(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '^127\.'))
    if [ ${#ip_list[@]} -ge 2 ]; then
        echo "${ip_list[1]}"
    elif [ ${#ip_list[@]} -ge 1 ]; then
        echo "${ip_list[0]}"
    else
        log "❌ 找不到任何有效的網路 IP"
        exit 1
    fi
}

# 檢查並加入規則（避免重複）
add_rule() {
    local CMD="$1"
    local RULE=$(echo "$CMD" | sed 's/^iptables\s\+\(.*\)$/\1/')

    if ! iptables-save | grep -F -- "$RULE" > /dev/null; then
        eval "$CMD"
        log "✔ 加入規則: $CMD"
    else
        log "➖ 已存在規則: $CMD"
    fi
}

# --- 取得網卡 IP ---
NETWORK_IP=$(get_network_ip)
log "🌐 使用網路 IP: $NETWORK_IP"

# --- 清單 ---
add_rule "iptables -t nat -N DOCKER"
add_rule "iptables -N DOCKER"
add_rule "iptables -N DOCKER-ISOLATION-STAGE-1"
add_rule "iptables -N DOCKER-ISOLATION-STAGE-2"
add_rule "iptables -N DOCKER-USER"
add_rule "iptables -P FORWARD DROP"
add_rule "iptables -A FORWARD -s 192.168.1.0/24 -j ACCEPT"
add_rule "iptables -A FORWARD -d 192.168.1.0/24 -j ACCEPT"
add_rule "iptables -A FORWARD -j DOCKER-USER"
add_rule "iptables -A FORWARD -j DOCKER-ISOLATION-STAGE-1"
add_rule "iptables -A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT"
add_rule "iptables -A FORWARD -o docker0 -j DOCKER"
add_rule "iptables -A FORWARD -i docker0 ! -o docker0 -j ACCEPT"
add_rule "iptables -A FORWARD -i docker0 -o docker0 -j ACCEPT"
add_rule "iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited"
add_rule "iptables -A DOCKER-ISOLATION-STAGE-1 -i docker0 ! -o docker0 -j DOCKER-ISOLATION-STAGE-2"
add_rule "iptables -A DOCKER-ISOLATION-STAGE-1 -j RETURN"
add_rule "iptables -A DOCKER-USER -j RETURN"
add_rule "iptables -A DOCKER-ISOLATION-STAGE-2 -o docker0 -j DROP"
add_rule "iptables -A DOCKER-ISOLATION-STAGE-2 -j RETURN"
add_rule "iptables -t nat -P PREROUTING ACCEPT"
add_rule "iptables -t nat -P POSTROUTING ACCEPT"
add_rule "iptables -t nat -P INPUT ACCEPT"
add_rule "iptables -t nat -P OUTPUT ACCEPT"
add_rule "iptables -t nat -A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER"
add_rule "iptables -t nat -A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE"
add_rule "iptables -t nat -A POSTROUTING -s 192.168.1.0/24 ! -d 192.168.0.0/16 -j SNAT --to-source $NETWORK_IP"
add_rule "iptables -t nat -A OUTPUT ! -d 127.0.0.0/8 -m addrtype --dst-type LOCAL -j DOCKER"
add_rule "iptables -t nat -A DOCKER -i docker0 -j RETURN"

log "✅ iptables 設定完成"
