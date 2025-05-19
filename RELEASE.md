# 📦 Web Tools Demo 發佈說明

> 本文件為系統封裝與版本發佈記錄，提供每次部署包內容與重大更新說明。

---

## 🔖 版本資訊

- **版本名稱**：v1.0.0
- **發佈日期**：2025/05/19
- **開發者**：MING-W
- **適用環境**：CentOS 7 / 8
- **部署方式**：Shell Script + docker-compose
- **容器技術**：Percona XtraDB Cluster 8.0、macvlan + Docker Compose

---

## 📁 發佈檔案目錄結構

```plaintext
web-tools-demo/
├─ install                 # 主部署腳本目錄
│  └─deploy_01~04.sh       # 部署腳本01~04
├─ scripts                 # 工具腳本目錄
│  ├─check_env.sh          # 環境檢查與日常診斷腳本
│  ├─macvlan.sh            # 建置docker的macvlan腳本
│  ├─backup_mysql.sh       # 備份資料庫腳本
│  └─show_info.sh          # 顯示系統資訊腳本
├─ nginx_sample.conf       # 範例 nginx 設定
├─ env.example             # 範例 env設定
├─ iptables.example        # 範例 iptables設定
├─ mysql-docker-compose.yml # 範例 node01的docker-compose設定
├─ backup/                 # 備份目錄
├─ docs/                   # 教學文檔（可另放 PDF 或影片）
└─ README.md
```

---

✨ 核心功能
一鍵部署 LEMP + PXC 環境

自動建立 VLAN macvlan 供容器使用固定 IP

自動產出基礎檢查報表（系統限制、防火牆、容器狀態）

完整部署腳本、README、ignore 設定

---

🆕 本版變更摘要（v1.0.0）
✅ 完成 deploy_01～04 部署流程設計

✅ 加入互動式主機名稱輸入

✅ macvlan.sh 腳本分離與啟動註冊設計

✅ Docker Compose 容器結構明確（支援擴充）

✅ check_env.sh 檢查主機、Nginx、PHP、容器網路

✅ 新增 README.md、.gitignore、RELEASE.md 結構

---
📌 發佈注意事項
請先確認實體機器第二張網卡名稱是否正確

安裝時請以 root 權限或 sudo 執行腳本

如需部署叢集，請修改 docker-compose.yml，啟用 CLUSTER_JOIN

---
🔧 後續開發方向（預告）
🔐 SSL/Nginx Proxy 模組整合

📈 Docker 容器資源監控（Prometheus）

🌐 Web UI 管理介面 + 整合簡易 CMS

📦 安裝包一鍵打包壓縮與備份腳本

© 2025 Web Tools Demo · Author: MING-W
