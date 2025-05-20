#!/bin/bash

echo "🚀 [部署第三步：建立 MySQL 容器目錄與啟動設定]"

# 1. 建立目錄結構
echo "📁 建立 /opt/pxc01 目錄結構..."
mkdir -p /opt/pxc01/var_lib_mysql
mkdir -p /opt/pxc01/var_log
mkdir -p /opt/pxc01/etc/mysql
mkdir -p /opt/pxc01/etc/my.cnf.d

# 2. 設定子目錄擁有者為 mysql
echo "🔐 設定子目錄權限為 mysql:mysql..."
chown -R mysql:mysql /opt/pxc01/var_lib_mysql
chown -R mysql:mysql /opt/pxc01/var_log
chown -R mysql:mysql /opt/pxc01/etc

# 3. 複製 pxc設定
echo "📄 複製 pxc容器設定 至 /opt/pxc01..."
if [ ! -f /opt/pxc01/etc/my.cnf ]; then
  cp ./web-tools-demo/example/my_example.cnf /opt/pxc01/etc/my.cnf
else
  echo "⚠️ /opt/pxc01/etc/my.cnf 已存在，略過複製"
fi

if [ ! -f /opt/pxc01/etc/mysql/node.cnf ]; then
  cp ./web-tools-demo/example/node_example.cnf /opt/pxc01/etc/mysql/node.cnf
else
  echo "⚠️ /opt/pxc01/etc/mysql/node.cnf 已存在，略過複製"
fi
cp ./web-tools-demo/example/mysql-docker-compose.yml /opt/pxc01/docker-compose.yml

# 4. 自動取得第二張網卡名稱
echo "🌐 偵測第二張網卡名稱..."
SECOND_IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | sed -n '2p')
echo "📌 使用網卡：$SECOND_IFACE"

# 5. 替換 docker-compose.yml 中的介面名稱
echo "🛠️ 替換 docker-compose.yml 中的 __REPLACE_WITH_INTERFACE__..."
sed -i "s/__REPLACE_WITH_INTERFACE__/$SECOND_IFACE/g" /opt/pxc01/docker-compose.yml

# 6. 替換 macvlan.sh 中的介面名稱
echo "🛠️ 替換 /opt/scripts/macvlan.sh 中的 __REPLACE_WITH_INTERFACE__..."
sed -i "s/__REPLACE_WITH_INTERFACE__/$SECOND_IFACE/g" /opt/scripts/macvlan.sh

# 7. 執行 macvlan.sh
echo "🚀 執行 /opt/scripts/macvlan.sh..."
bash /opt/scripts/macvlan.sh

# 8. 顯示 VLAN 網卡設定狀態
echo "🔍 檢查 vlan0001 網卡是否建立並正確連接："
ip link show vlan0001 || echo "⚠️ vlan0001 尚未建立"

# 9. 顯示 VLAN 網卡 IP 設定與連結資訊
echo "📡 VLAN 詳細資訊（若存在）:"
ip -d link show vlan0001 2>/dev/null || echo "⚠️ vlan0001 詳細資訊無法取得"

# 10. 顯示 docker 網路狀態
echo "🐳 Docker 網路列表："
docker network ls

echo "🔎 vlan0001 網路詳細資訊："
docker network inspect vlan0001 2>/dev/null || echo "⚠️ 尚未建立 docker 網路 vlan0001"

echo "✅ deploy_03.sh 執行完成：容器目錄與網路設定完成"