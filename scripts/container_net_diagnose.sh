#!/bin/bash

# 用法：./net_diagnose.sh <container_name> <target_ip_or_host>
# 範例：./net_diagnose.sh wp01 8.8.8.8

CONTAINER_NAME="$1"
TARGET="$2"

if [ -z "$CONTAINER_NAME" ] || [ -z "$TARGET" ]; then
  echo "❌ 用法錯誤：請輸入容器名稱與目標 IP 或域名"
  echo "用法：$0 <container_name> <target_ip_or_hostname>"
  exit 1
fi

echo "🩺 使用容器 $CONTAINER_NAME 執行網路診斷：$TARGET"

docker run --rm --network container:"$CONTAINER_NAME" alpine sh -c "
  apk add --no-cache iputils busybox bind-tools traceroute netcat-openbsd > /dev/null

  echo ''
  echo '🔧 IP 設定：'
  ip a

  echo ''
  echo '🔧 路由表：'
  ip route

  echo ''
  echo '🔧 DNS 查詢：'
  nslookup $TARGET || getent hosts $TARGET

  echo ''
  echo '🔧 Traceroute 路徑：'
  traceroute -m 10 $TARGET || echo 'traceroute 失敗或不支援'

  echo ''
  echo '🔧 檢查 80 埠是否開啟：'
  nc -zvw3 $TARGET 80 || echo '❌ 無法連線到 $TARGET:80'

  echo ''
  echo '🧯 診斷完成。請依照結果判斷問題。'
"
