#!/bin/bash

echo "🧪 環境整體健康檢查開始"

check() {
  "$@" &> /dev/null && echo "✅ $*" || echo "❌ $*"
}

echo "🔧 檢查主機名稱..."
hostnamectl | grep "Static hostname: website01" &> /dev/null && echo "✅ Hostname 為 website01" || echo "❌ Hostname 非 website01"

echo "🕒 檢查時區設定..."
timedatectl | grep "Time zone: Asia/Taipei" &> /dev/null && echo "✅ 時區為 Asia/Taipei" || echo "❌ 時區非 Asia/Taipei"

echo "📋 system.conf 限制設定..."
grep -q "DefaultLimitCORE=infinity" /etc/systemd/system.conf && echo "✅ DefaultLimitCORE 設定正確" || echo "❌ DefaultLimitCORE 未設定"
grep -q "DefaultLimitNOFILE=64000" /etc/systemd/system.conf && echo "✅ DefaultLimitNOFILE 設定正確" || echo "❌ DefaultLimitNOFILE 未設定"
grep -q "DefaultLimitNPROC=64000" /etc/systemd/system.conf && echo "✅ DefaultLimitNPROC 設定正確" || echo "❌ DefaultLimitNPROC 未設定"

echo "⚙️ 核心參數套用狀態..."
sysctl vm.max_map_count | grep 262144 && echo "✅ vm.max_map_count 設定正確" || echo "❌ vm.max_map_count 設定錯誤"
sysctl net.ipv4.ip_forward | grep 1 && echo "✅ ip_forward 啟用中" || echo "❌ ip_forward 未啟用"

echo "🌐 Nginx 狀態..."
check nginx -v
check systemctl is-active nginx

echo "📦 PHP 與 php-fpm 狀態..."
check php -v
check php -m | grep -q "mysqli"
# 檢查 php-fpm 是否有在執行
if ps aux | grep -v grep | grep -q "php-fpm"; then
    echo "✅ PHP-FPM 程序已啟動"
    
    # 檢查是否為 nginx user
    FPM_USER=$(ps -eo user,cmd | grep 'php-fpm: pool www' | awk '{print $1}' | sort | uniq)
    if echo "$FPM_USER" | grep -q "nginx"; then
        echo "✅ PHP-FPM 執行者為 nginx"
    else
        echo "❌ PHP-FPM 執行者不是 nginx：$FPM_USER"
    fi
else
    echo "❌ PHP-FPM 程序未啟動"
fi

# 檢查是否監聽在 127.0.0.1:9000
if netstat -tnlp 2>/dev/null | grep -q "127.0.0.1:9000"; then
    echo "✅ PHP-FPM 正確監聽在 127.0.0.1:9000"
else
    echo "❌ PHP-FPM 未監聽在 127.0.0.1:9000"
fi
check systemctl is-active php-fpm

# 檢查 /etc/rc.local 是否已有 macvlan.sh
grep -q "/opt/scripts/macvlan.sh" /etc/rc.local && \
  echo "✅ rc.local 已設定 macvlan.sh 啟動" || \
  echo "❌ rc.local 未設定 macvlan.sh"


echo "🐳 Docker 與 Compose..."
check docker -v
check systemctl is-active docker
check docker-compose -v

echo "🛡️ SELinux 狀態..."
getenforce | grep -i Disabled && echo "✅ SELinux 已關閉" || echo "❌ SELinux 未關閉"

echo "🔥 防火牆設定..."
check systemctl is-enabled iptables
check iptables -L -n | grep -q "tcp dpt:80"
check iptables -L -n | grep -q "tcp dpt:443"

echo "📡 VLAN 與 Docker 網路..."
ip link show vlan0001 &> /dev/null && echo "✅ vlan0001 網卡存在" || echo "❌ vlan0001 網卡不存在"
docker network inspect vlan0001 &> /dev/null && echo "✅ Docker vlan0001 存在" || echo "❌ Docker vlan0001 不存在"

echo "📦 容器狀態檢查..."
docker ps --filter name=node01 | grep -q "Up" && echo "✅ node01 容器已啟動" || echo "❌ node01 容器未啟動"

echo "🧪 檢查完成"
