<style>
red {color: #e84646;}
blue {color: #4169E1;} 
yellow {
  color:black;
  background-color: #ffdd00;
} 
green {
  color:black;
  background-color: #28FF28;
}
</style>

# 🧰 Web Tools Demo - 一站式智慧導入平台部署腳本

這是一份針對 CentOS 7/8 環境設計的自動化部署腳本，提供完整的<blue>網站架構建置、PHP-FPM、Nginx、Docker 與 PXC 資料庫環境初始化流程</blue>。適合中小企業、獨立開發者快速啟用智慧服務平台。

---

## 📋 系統需求

- 作業系統：CentOS 7 / CentOS 8（實體或虛擬機）
- 權限：root 使用者或 sudo 權限
- 已安裝 git 指令工具

---

## 📁 專案結構說明
```bash
web-tools-demo/
├─ install                 # 主部署腳本目錄
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

## 📁 安裝前準備

```bash
# 安裝 git 並下載專案
yum install -y git
git clone https://github.com/Git-MING-W/web-tools-demo.git
```

🚀 安裝流程
### 第一步：顯示系統資訊
```bash
bash ./web-tools-demo/scripts/show_info.sh
```
確認系統 CPU、RAM、磁碟空間、OS 版本與時區設定。

### 第二步：執行主部署 CLI 腳本
可以依照順序一步步執行，也可以輸入a直接全部一次執行，<red>請不要跳著順序執行</red>，後續步驟會依賴前方步驟部屬的檔案和環境。
```bash
bash ./web-tools-demo/install/install.sh
```

### 第三步：重新啟動服務器與清理部屬腳本
```bash
rm -rf /root/web-tools-demo
reboot
```
- 🔄 重啟伺服器 以使 SELinux、system.conf、sysctl 等設定生效。
- 🧹 清理部署腳本 可避免日後誤觸、重複執行或外洩敏感配置。
- 📁 日常維運腳本 已自動複製至 /opt/scripts/，可直接使用。


### 日常診斷與注意事項
🩺 環境檢查與日常診斷
```bash
bash /opt/scripts/check_env.sh
```
檢查內容包括：
- 主機設定（hostname、timezone）
- nginx / php-fpm / docker 運行狀態
- 端口監聽 / SELinux / iptables
- macvlan 網路與容器運作狀態

📌 <red>注意事項</red>

- docker-compose.yml 中的 `__REPLACE_WITH_INTERFACE__` 會由腳本自動替換
- 若部署多節點，請取消註解 CLUSTER_JOIN 並移除 --wsrep-new-cluster
- deploy_04.sh 啟動為單節點，僅供開發與驗證用途

📌 <red>加入叢集注意事項（PXC 多節點部署）</red>

Percona 官方映像檔不會自動將 `CLUSTER_JOIN` 環境變數套用進 `node.cnf`，請根據節點角色調整：
#### Node01（第一節點）
```yaml
environment:
  - CLUSTER_JOIN=
此時 node.cnf的wsrep_cluster_address 會為空（gcomm://），代表建立新叢集。
```

#### Node02+（加入叢集的節點）
```yaml
environment:
  - CLUSTER_JOIN=192.168.1.25
```
請手動指定第一節點 IP，必要時可加入多個節點做容錯：
```yaml
  - CLUSTER_JOIN=192.168.1.25,192.168.1.26
```

你也可以手動編輯 /opt/pxc02/etc/mysql/node.cnf(依環境需求調整)：
```
server_id = 每台節點要不同
wsrep_node_address = 本節點實際IP
wsrep_node_incoming_address = 本節點實際IP:3306
wsrep_cluster_address = gcomm://指向 node01 IP(或其他多節點IP)
```
⚠️ 若自行設定 node.cnf，請確保容器有對應 volume 掛載並 reload 後啟動。

---
📚 後續建議擴充
- 加入 .env 支援參數集中管理
- 新增 uninstall.sh 或 deploy_node02.sh
- 整合 SSL/Nginx Proxy / Prometheus 監控模組


🎬 使用範例截圖 / 示意影片（可放圖片或連結）
📺 示範影片：https://youtu.be/xxxxxxxxxxx

---

🧑‍🏫 延伸教學與說明文件
技術教學文章 - 自動備份與通知教學

使用者設定常見問題（FAQ）

更新紀錄與版本變更

🧑‍💼 作者與聯絡方式
作者：Git-Ming-W

職業：系統工程師／架站顧問

Email：

LINE ID：

個人網站：

📜 授權條款
MIT License — 歡迎商用／修改／重製，請保留原始作者資訊。

© 2025 Web Tools Demo — Maintained by [MING-W]

