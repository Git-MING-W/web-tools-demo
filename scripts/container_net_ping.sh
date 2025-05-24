#!/bin/bash

# 確保 fzf 存在
if ! command -v fzf &> /dev/null; then
  echo "❌ 請先安裝 fzf 工具才能使用互動式選單功能"
  echo "yum install -y fzf"
  echo "上述指令無法安裝或找不到套件，請參考：https://github.com/junegunn/fzf"
  exit 1
fi

# 取得正在執行中的容器清單
CONTAINER_LIST=$(docker ps --format '{{.Names}}')

# 若無 container 運行
if [ -z "$CONTAINER_LIST" ]; then
  echo "❌ 目前沒有正在執行的容器，請先啟動至少一個容器再執行此腳本。"
  exit 1
fi

# 使用 fzf 選擇容器
echo "📦 請選擇要使用的容器（上下鍵選擇，Enter 確認）："
CONTAINER_NAME=$(echo "$CONTAINER_LIST" | fzf --prompt="容器名稱 > ")

# 若使用者取消選取
if [ -z "$CONTAINER_NAME" ]; then
  echo "❌ 未選擇任何容器，已取消操作。"
  exit 1
fi

# 第二個參數為 target（IP 或域名），若無則預設
TARGET="${1:-192.168.100.1}"

echo "🔍 使用容器 $CONTAINER_NAME 測試與 $TARGET 的連線狀態..."
docker run --rm --network container:"$CONTAINER_NAME" alpine sh -c "
  apk add --no-cache iputils > /dev/null &&
  ping -c 4 $TARGET
" || {
  echo "⚠️ 無法連線到 $TARGET，啟動網路診斷..."
  /opt/scripts/net_diagnose.sh "$CONTAINER_NAME" "$TARGET"
}


