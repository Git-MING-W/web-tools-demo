#!/bin/bash

echo "🔍 [1] 機器系統環境檢查"

# 顯示 CPU 資訊
echo "🧠 CPU 資訊："
command -v lscpu >/dev/null && lscpu | grep -E 'Model name|Socket|Core|Thread|CPU\(s\)' || echo "⚠️ 無 lscpu 指令"

# 顯示 RAM
echo "💾 RAM 資訊："
free -h || echo "⚠️ 無 free 指令"

# 顯示硬碟分割與使用
echo "🗄️ 磁碟分割與使用狀況："
lsblk || echo "⚠️ 無 lsblk 指令"
df -h || echo "⚠️ 無 df 指令"

# 顯示作業系統與版本
echo "📦 系統版本："
grep PRETTY_NAME /etc/os-release || cat /etc/os-release

# 顯示目前時區
echo "🕒 目前時區："
timedatectl | grep "Time zone" || echo "⚠️ 無 timedatectl 或顯示失敗"

echo "===== 網卡資訊（含 IP） ====="
ip -4 addr show | awk '/^[0-9]+:/ { iface=$2 } /inet / { print iface, $2 }'

echo ""
echo "===== 常見服務埠口檢查 ====="
for port in 80 443 3306 9000; do
  if ss -tuln | grep -q ":$port "; then
    echo "✅ 埠 $port 已啟用"
  else
    echo "❌ 埠 $port 尚未啟用"
  fi
done

echo "✅ 系統環境列印完成"
echo "-------------------------------------"