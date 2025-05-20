# 📦 Web Tools Demo 發佈說明

> 本文件為系統封裝與版本發佈記錄，提供每次部署包內容與重大更新說明。

---

## 🔖 版本資訊

- **版本名稱**：v1.0.1
- **發佈日期**：2025/05/21
- **開發者**：MING-W
- **適用環境**：CentOS 7 / 8 / Rocky Linux 8+
- **部署方式**：Shell Script + docker-compose
- **容器技術**：Percona XtraDB Cluster 8.0、macvlan + Docker Compose

---

## 📁 發佈檔案目錄結構

```bash
web-tools-demo/
├─ install                 # 主部署腳本目錄
│  └─deploy_01~04.sh       # 部署腳本01~04
├─ scripts                 # 工具腳本目錄
│  ├─check_env.sh          # 環境檢查與日常診斷腳本
│  ├─macvlan.sh            # 建置docker的macvlan腳本
│  ├─backup_mysql.sh       # 備份資料庫腳本
│  └─show_info.sh          # 顯示系統資訊腳本
├─ example                 # 範例目錄 
│  ├─nginx_sample.conf     # 範例 nginx 設定
│  ├─env.example           # 範例 env設定
│  ├─iptables.example      # 範例 iptables設定
│  ├─mysql-docker-compose.yml # 範例 node01的docker-compose設定
│  ├─my_example.cnf        # 範例 node01的my.cnf設定
│  └─node_example.cnf      # 範例 node01的node.cnf設定
├─ backup/                 # 備份目錄
├─ docs/                   # 教學文檔（可另放 PDF 或影片）
├─ RELEASE.md
└─ README.md
```

---

🆕 本版變更摘要（v1.0.1）

✅ `show_info.sh` 增加以下檢查功能：
  - 顯示網卡名稱與 IP 資訊
  - 檢查常見服務埠（80, 443, 3306, 9000）是否啟用

✅ `deploy_02.sh` 中強化 SELinux 處理：
  - 同時支援 `/etc/selinux/config` 與 `/etc/sysconfig/selinux`
  - 加入當前狀態判斷與提示

✅ `deploy_03.sh` 中新增：
  - 自動複製 `example/my_example.cnf` 為 `my.cnf`
  - 自動複製 `example/node_example.cnf` 為 `node.cnf`
  - 自動取代介面名稱與執行 `macvlan.sh` 並檢查結果

✅ `README.md` 增補第六步：
  - 部署完成後需 `reboot` 才能使系統參數生效
  - 清理 `/root/web-tools-demo` 腳本目錄以防外洩或誤操作

✅ `RELEASE.md` 補充 v1.0.1 變更紀錄

---
📌 發佈注意事項（續）

- 設定檔預設為範例版本，部署後請視需求微調
- 若使用 `CLUSTER_JOIN` 部署多節點，請記得調整以下參數：
  - `server_id`
  - `wsrep_node_address`
  - `wsrep_node_incoming_address`
  - `wsrep_cluster_address`

---
🧭 後續建議操作

- 請於部署完成後立即重啟主機 (`reboot`)
- 移除部署腳本目錄 `/root/web-tools-demo`
- 日常維運腳本已複製至 `/opt/scripts/`

---
🔧 後續開發方向（預告）
🔐 SSL/Nginx Proxy 模組整合

📈 Docker 容器資源監控（Prometheus）

🌐 Web UI 管理介面 + 整合簡易 CMS

📦 安裝包一鍵打包壓縮與備份腳本

© 2025 Web Tools Demo · Author: MING-W
