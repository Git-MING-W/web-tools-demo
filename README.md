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
│  └─show_info.sh          # 顯示系統資訊腳本
├─ nginx_sample.conf       # 範例 nginx 設定
├─ env.example             # 範例 env設定
├─ iptables.example        # 範例 iptables設定
├─ mysql-docker-compose.yml # 範例 node01的docker-compose設定
├─ backup/                 # 備份目錄
├─ docs/                   # 教學文檔（可另放 PDF 或影片）
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

### 第二步：主機初始化與網頁環境建置
```bash
bash ./web-tools-demo/install/deploy_01.sh
```
內容包括：
- 主機名稱設定（互動式輸入）
- 設定時區為台北
- 調整系統限制與核心參數（ulimit/sysctl）
- 安裝 Nginx 與首頁

### 第三步：安裝 PHP、Docker 與系統服務設定
```bash
bash ./web-tools-demo/install/deploy_02.sh
```
- 安裝 PHP + 常用模組，設定為 nginx 使用
- 啟用 PHP-FPM 並開放 port 9000
- 安裝 Docker + 舊版 docker-compose CLI
- 設定 macvlan 腳本與 rc.local 開機啟動
- 關閉 SELinux、安裝 iptables、停用 firewalld

### 第四步：建立 PXC 容器目錄與網卡設定
```bash
bash ./web-tools-demo/install/deploy_03.sh
```
- 建立 /opt/pxc01 及目錄結構
- 複製 docker-compose.yml 並替換實體網卡變數
- 執行 macvlan 腳本並建立 VLAN0001 網卡
- 顯示 docker network 狀態與確認容器網路

### 第五步：啟動容器與初步健康檢查
```bash
bash ./web-tools-demo/install/deploy_04.sh
```
- 使用 docker-compose 啟動 MySQL 容器
- 顯示目前容器狀態與 logs 檢查（含 wsrep 狀態）

🩺 環境檢查與日常診斷
```bash
bash ./web-tools-demo/scripts/check_env.sh
```
檢查內容包括：
- 主機設定（hostname、timezone）
- nginx / php-fpm / docker 運行狀態
- 端口監聽 / SELinux / iptables
- macvlan 網路與容器運作狀態

📌 <red>注意事項</red>

- <red>docker-compose.yml 中的 `__REPLACE_WITH_INTERFACE__` 會由腳本自動替換</red>
- <red>若部署多節點，請取消註解 CLUSTER_JOIN 並移除 --wsrep-new-cluster</red>
- <red>deploy_04.sh 啟動為單節點，僅供開發與驗證用途</red>


📚 後續建議擴充
- 加入 .env 支援參數集中管理
- 新增 uninstall.sh 或 deploy_node02.sh
- 整合 SSL/Nginx Proxy / Prometheus 監控模組


🎬 使用範例截圖 / 示意影片（可放圖片或連結）
📺 示範影片：https://youtu.be/xxxxxxxxxxx

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

