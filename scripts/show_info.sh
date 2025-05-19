#!/bin/bash

echo "🔍 [1] 機器系統環境檢查"

# 顯示 CPU 資訊
echo "🧠 CPU 資訊："
lscpu | grep -E 'Model name|Socket|Core|Thread|CPU(s)'

# 顯示 RAM
echo "💾 RAM 資訊："
free -h

# 顯示硬碟分割與使用
echo "🗄️ 磁碟分割與使用狀況："
lsblk
df -h

# 顯示作業系統與版本
echo "📦 系統版本："
cat /etc/os-release

# 顯示目前時區
echo "🕒 目前時區："
timedatectl

echo "✅ 系統環境列印完成"
echo "-------------------------------------"