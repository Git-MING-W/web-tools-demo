#!/bin/bash

echo "🚀 [部署第四步：啟動容器並進行狀態檢查]"

COMPOSE_FILE="/opt/pxc01/docker-compose.yml"

# 確認 compose 檔案是否存在
if [ ! -f "$COMPOSE_FILE" ]; then
  echo "❌ 錯誤：找不到 $COMPOSE_FILE，請確認部署是否完成"
  exit 1
fi

# 使用絕對路徑啟動容器
echo "🐳 使用 docker-compose 啟動容器..."
docker-compose -f "$COMPOSE_FILE" up -d

# 確認容器是否啟動
echo "📦 檢查容器是否成功啟動..."
docker ps --filter name=node01

# 等待 MySQL 初始化
echo "⏳ 等待 10 秒讓 PXC 容器啟動..."
sleep 10

# 顯示 docker-compose log
echo "🧾 顯示 docker-compose log（查看啟動與 wsrep 狀態）..."
docker-compose -f "$COMPOSE_FILE" logs --tail=50

# Optional 健康檢查指令（可視需要打開）
docker exec -it node01 mysql -uroot -p -e "SHOW STATUS LIKE 'wsrep_ready';"

echo "✅ 容器啟動與初步檢查完成，請手動確認 log 是否正常"