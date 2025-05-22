#!/bin/bash

echo "🚀 [初始化與安裝 nginx]"

# 1. 設定主機名稱
echo "🖥️ 設定主機名稱為 website01..."
read -p "請輸入要設定的主機名稱（hostname）: " NEW_HOSTNAME
if [ -n "$NEW_HOSTNAME" ]; then
  hostnamectl set-hostname "$NEW_HOSTNAME"
  echo "✅ 主機名稱已設為：$NEW_HOSTNAME"
else
  echo "❌ 未輸入主機名稱，跳過設定。"
  exit 1
fi

# 2a. 設定時區
echo "🌐 設定時區為 Asia/Taipei..."
timedatectl set-timezone Asia/Taipei

# 2b. 增加mysql使用，並使用指定ID
# 檢查 mysql 群組是否存在
if getent group mysql > /dev/null; then
  echo "✅ 群組 mysql 已存在，GID: $(getent group mysql | cut -d: -f3)"
else
  groupadd -g 1001 mysql
  echo "✅ 已建立群組 mysql (GID 1001)"
fi

# 檢查 mysql 使用者是否存在
if id mysql &>/dev/null; then
  echo "✅ 使用者 mysql 已存在，UID: $(id -u mysql), GID: $(id -g mysql)"
else
  useradd -u 1001 -g 1001 -r -s /sbin/nologin mysql
  echo "✅ 已建立使用者 mysql (UID 1001)"
fi

# 檢查 www-data 使用者是否存在
if id www-data &>/dev/null; then
  echo "✅ 使用者 www-data 已存在，UID: $(id -u www-data), GID: $(id -g www-data)"
else
  useradd -u 33 -g 33 -r -s /sbin/nologin www-data
  echo "✅ 已建立使用者 www-data (UID 33)"
fi

# 3a. 設定 /etc/systemd/system.conf 系統限制參數
echo "📝 設定 system.conf 系統限制參數..."
sed -i '/^DefaultLimitCORE=/d' /etc/systemd/system.conf
sed -i '/^DefaultLimitNOFILE=/d' /etc/systemd/system.conf
sed -i '/^DefaultLimitNPROC=/d' /etc/systemd/system.conf
echo "DefaultLimitCORE=infinity"   | tee -a /etc/systemd/system.conf
echo "DefaultLimitNOFILE=64000"    | tee -a /etc/systemd/system.conf
echo "DefaultLimitNPROC=64000"     | tee -a /etc/systemd/system.conf
echo "✅ 已更新 system.conf 系統限制參數"

# 3b. 設定系統核心參數（sysctl.conf）
echo "📝 設定 sysctl.conf 系統參數..."
sed -i '/^vm.max_map_count/d' /etc/sysctl.conf
sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
sed -i '/^net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
sed -i '/^net.ipv4.tcp_tw_recycle/d' /etc/sysctl.conf
sed -i '/^net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
sed -i '/^net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf

cat <<EOF >> /etc/sysctl.conf

# 自訂網路與記憶體優化參數
vm.max_map_count=262144
net.ipv4.ip_forward = 1 
net.ipv4.tcp_fin_timeout = 10 
#net.ipv4.tcp_tw_recycle = 1 
net.ipv4.tcp_max_tw_buckets = 100 
net.ipv4.tcp_tw_reuse = 1
EOF

sysctl -p
echo "✅ 系統核心參數已設定並套用"

# 3c. 註解掉本機 IPv6 解析
sed -i 's/^::1/#::1/' /etc/hosts
echo "✅ 已註解本機 IPv6 解析"

# 4. 安裝 EPEL 套件庫
echo "📦 安裝 EPEL 套件庫..."
yum -y install epel-release

echo "📦 安裝 常用基本 套件..."
yum install -y wget unzip lrzsz net-tools network-scripts

# 5. 設定 nginx 官方 yum repo
echo "🗂️ 設定 nginx 官方 yum repo..."
cat <<EOF > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo 
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/ 
gpgcheck=1 
enabled=1 
gpgkey=https://nginx.org/keys/nginx_signing.key 
module_hotfixes=true 
EOF

# 6. 更新 yum 套件清單
echo "🔄 更新 yum 套件清單..."
yum makecache

# 7. 安裝 nginx
echo "📦 安裝 nginx..."
yum install -y nginx

# 8. 建立網站首頁
echo "📁 建立網站根目錄與首頁..."
# 建立資料夾
mkdir -p /var/cache/nginx/wp
mkdir -p /var/cache/nginx/api
mkdir /etc/nginx/snippets/
mkdir -p /var/www/html/php

# 將 conf/ 下的設定檔複製到 Nginx 設定目錄
echo "<?php phpinfo(); ?>" > /var/www/html/php/index.php
cp ./web-tools-demo/example/nginx-sample.conf /etc/nginx/nginx.conf
cp ./web-tools-demo/example/cache_zones.conf /etc/nginx/snippets/
cp ./web-tools-demo/conf/*.conf /etc/nginx/conf.d/

# 設定own
chown -R nginx:nginx /var/cache/nginx
chown -R nginx:nginx /var/www/html

systemctl start nginx
systemctl enable nginx


echo "✅ 初始化與 nginx 安裝完成"