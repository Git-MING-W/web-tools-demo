# 📦 Web Tools Demo 發佈說明

> 本文件為系統封裝與版本發佈記錄，提供每次部署包內容與重大更新說明。

---

## 🔖 版本資訊

- **版本名稱**：v1.0.3
- **發佈日期**：2025/05/22
- **開發者**：MING-W
- **適用環境**：CentOS 7 / 8 / Rocky Linux 8+
- **部署方式**：Shell Script + docker-compose
- **容器技術**：Percona XtraDB Cluster 8.0、macvlan + Docker Compose

---

## 📁 發佈檔案目錄結構

```bash
web-tools-demo/
├─ install                 # 主部署腳本目錄
│  ├─install.sh            # 安裝主控腳本
│  └─deploy_01~04.sh       # 部署腳本01~04
├─ scripts                 # 工具腳本目錄
│  ├─check_env.sh          # 環境檢查與日常診斷腳本
│  ├─macvlan.sh            # 建置docker的macvlan腳本
│  ├─backup_mysql.sh       # 備份資料庫腳本
│  ├─only_apply_ssl.sh     # 申請證書腳本
│  ├─auto_apply_ssl.sh     # 自動化申請證書及替換腳本 
│  ├─container_net_diagnose.sh # 容器網路環境檢查
│  ├─container_net_ping.sh # 容器網路測試
│  ├─add_macvlan_iptable.sh # 添加macvlan防火牆規則
│  └─show_info.sh          # 顯示系統資訊腳本
├─ example                 # 範例目錄 
│  ├─nginx_sample.conf     # 範例 nginx 設定
│  ├─env.example           # 範例 env設定
│  ├─iptables.example      # 範例 iptables設定
│  ├─mysql-docker-compose.yml # 範例 node01的docker-compose設定
│  ├─my_example.cnf        # 範例 node01的my.cnf設定
│  ├─cache_zones.conf      # proxy cache緩衝區設定
│  └─node_example.cnf      # 範例 node01的node.cnf設定
├─ conf/                   # nginx conf設定範本
│  ├─ default.conf         # 預設頁
│  ├─ localhost.conf       # 檢測狀態頁面
│  └─ php_info.conf        # php資訊
├─ backup/                 # 備份目錄
├─ docs/                   # 教學文檔（可另放 PDF 或影片）
├─ RELEASE.md
└─ README.md
```

---
🆕 本版變更摘要（v1.0.0）

✅ 完成 deploy_01～04 部署流程設計

✅ 加入互動式主機名稱輸入

✅ macvlan.sh 腳本分離與啟動註冊設計

✅ Docker Compose 容器結構明確（支援擴充）

✅ check_env.sh 檢查主機、Nginx、PHP、容器網路

✅ 新增 README.md、.gitignore、RELEASE.md 結構

---

🆕 本版變更摘要（v1.0.1）
✅ `README.md` 增補第六步：
  - 部署完成後需 `reboot` 才能使系統參數生效
  - 清理 `/root/web-tools-demo` 腳本目錄以防外洩或誤操作

✅ `RELEASE.md` 補充 v1.0.1 變更紀錄

---

🆕 本版變更摘要（v1.0.2）

✅ `deploy_01.sh` 中增加初始化nginx環境配置：
  - 加入`default`、`localhost`、`php_info`站點配置
  - 優化nginx.conf配置
  - 加入`cache_zones`配置

✅ `deploy_02.sh` 中新增：
  - 補正iptable設定沒存檔問題

✅ 新增`auto_apply_ssl.sh`、`only_apply_ssl.sh`腳本：
  - 新增`auto_apply_ssl.sh`腳本可用容器化的方式申請Let's Encrypt證書並自動替代指定路徑conf內證書
  - 新增`only_apply_ssl.sh`腳本可用容器化的方式申請Let's Encrypt證書

✅ `RELEASE.md` 補充 v1.0.2 變更紀錄

---
🆕 本版變更摘要（v1.0.3）

✅ 運維工具新增`container_net_diagnose.sh`、`container_net_ping.sh`：
  - `container_net_diagnose.sh` 可做指定 容器的網路環境檢查
  - `container_net_ping.sh`  可做指定 容器 對域名或ip的網路測試
  - `add_macvlan_iptable.sh` 添加macvlan防火牆規則

✅ `deploy_02.sh` 中調整：
  - 修改php安裝版本為8.2(請自行確認系統有支援)
  - 使用腳本add_macvlan_iptable.sh添加iptables規則

✅ 新增`install.sh`安裝主控腳本，可提供 選單導引 CLI。

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

---

📬 若您有任何建議或錯誤回報，請於 [GitHub Issues](https://github.com/Git-MING-W/wordpress_module/issues) 提出。

© 2025 Web Tools Demo · Author: MING-W
