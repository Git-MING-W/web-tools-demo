#!/bin/bash

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/var/log/deploy_install.log"
STATE_FILE="/var/log/deploy_install.state"

# 建立狀態檔（若不存在）
touch "$STATE_FILE"

log() {
    echo "$(date '+%F %T') $1" | tee -a "$LOG_FILE"
}

# ✅ 狀態管理工具
mark_done() {
    echo "$1=done" >> "$STATE_FILE"
}

is_done() {
    grep -q "^$1=done" "$STATE_FILE"
}

confirm_redo() {
    read -p "⚠️ [$1] 已完成，是否重新執行？(y/N): " ans
    [[ "$ans" =~ ^[Yy]$ ]]
}

# ✅ 各階段部署封裝
deploy_step() {
    local STEP_ID="$1"
    local DESC="$2"
    local SCRIPT="$SCRIPT_PATH/deploy_${STEP_ID}.sh"

    if is_done "$STEP_ID"; then
        if confirm_redo "$DESC"; then
            bash "$SCRIPT" && log "🔁 重新執行 $DESC 完成"
        else
            log "⏭️  略過 $DESC"
            return
        fi
    else
        log "▶ 執行 $DESC..."
        bash "$SCRIPT" && mark_done "$STEP_ID" && log "✅ $DESC 完成"
    fi
}

# ✅ 主選單
main_menu() {
    while true; do
        clear
        echo "🛠️  部署引導工具 (Rocky Linux 專用)"
        echo "========================================"
        echo "  1. 部署步驟一：主機初始化與網頁環境建置"
        echo "  2. 部署步驟二：安裝 PHP、Docker 與系統服務設定"
        echo "  3. 部署步驟三：建立 PXC 容器目錄與網卡設定"
        echo "  4. 部署步驟四：啟動容器與初步健康檢查"
        echo "  a. 全部依序執行（支援斷點續跑）"
        echo "  r. 重置部署狀態（重新開始）"
        echo "  q. 離開"
        echo "========================================"
        read -p "請選擇執行項目（1/2/3/4/a/r/q）: " CHOICE

        case "$CHOICE" in
            1) deploy_step 01 "步驟一：主機初始化與網頁環境建置" ;;
            2) deploy_step 02 "步驟二：安裝 PHP、Docker 與系統服務設定" ;;
            3) deploy_step 03 "步驟三：建立 PXC 容器目錄與網卡設定" ;;
            4) deploy_step 04 "步驟四：啟動容器與初步健康檢查" ;;
            a)
                deploy_step 01 "步驟一：主機初始化與網頁環境建置"
                deploy_step 02 "步驟二：安裝 PHP、Docker 與系統服務設定"
                deploy_step 03 "步驟三：建立 PXC 容器目錄與網卡設定"
                deploy_step 04 "步驟四：啟動容器與初步健康檢查"
                ;;
            r)
                echo "🧹 正在重置狀態記錄..."
                rm -f "$STATE_FILE"
                touch "$STATE_FILE"
                log "🔄 狀態已重置。"
                ;;
            q|Q)
                echo "👋 再見！"
                exit 0
                ;;
            *)
                echo "❌ 無效選項，請重新選擇。"
                ;;
        esac
        echo "✅ 任務完成，按 Enter 回到主選單..."
        read
    done
}

main_menu
