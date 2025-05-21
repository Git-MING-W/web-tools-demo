#!/bin/bash

echo "🚀 [部署第二步：安裝 PHP、Docker、Firewall 設定]"

# 1. 安裝 PHP 及模組
echo "📦 安裝 PHP 及常見模組..."
yum install -y php php-fpm php-mysqlnd php-cli php-gd php-xml php-mbstring php-common php-process php-intl php-devel php-zip

echo "⚙️ 調整 php-fpm 設定：listen port 與 nginx 使用者..."

# 修改 listen 為 127.0.0.1:9000
sed -i 's|^listen = .*|listen = 127.0.0.1:9000|' /etc/php-fpm.d/www.conf

# 修改 user/group 為 nginx
sed -i 's/^user = .*/user = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/^group = .*/group = nginx/' /etc/php-fpm.d/www.conf

# 啟用與啟動 php-fpm
echo "🚀 啟動 php-fpm 並設為開機自動執行..."
systemctl enable php-fpm
systemctl start php-fpm

# 2. 安裝 Docker 和 Docker Compose
echo "🐳 安裝 Docker 與 Docker Compose..."
yum install -y yum-utils 
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io 
curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
systemctl enable docker
systemctl start docker

# 3. 建立 /opt/scripts 並複製 macvlan.sh
echo "📁 建立 /opt/scripts 並複製 macvlan.sh..."
mkdir -p /opt/scripts
cp ./web-tools-demo/scripts/* /opt/scripts/
chmod +x /opt/scripts/*.sh

# 4. 設定 macvlan.sh 開機啟動
echo "🔁 設定 macvlan.sh 開機自動執行..."
echo "/opt/scripts/macvlan.sh" >> /etc/rc.local
chmod +x /etc/rc.d/rc.local

# 5. 關閉 SELinux
echo "🛡️ 關閉 SELinux 並設為 disabled..."
setenforce 0
SELINUX_CFG="/etc/sysconfig/selinux"
if [ -f /etc/selinux/config ]; then
  SELINUX_CFG="/etc/selinux/config"
fi

sed -i 's/^SELINUX=.*/SELINUX=disabled/' "$SELINUX_CFG"
echo "✅ SELinux 設定為 disabled（請重新開機以生效）"

# 6. 安裝 ipset 並啟用
echo "📦 安裝 ipset 並啟用..."
yum install -y ipset
systemctl enable ipset
systemctl start ipset

# 7. 安裝 iptables 和 iptables-services
echo "📦 安裝 iptables 與 iptables-services..."
yum install -y iptables iptables-services

# 8. 停用 firewalld 並取消開機啟動
echo "🔥 停用 firewalld..."
systemctl stop firewalld
systemctl disable firewalld

# 9. 啟用 iptables 並設成開機啟用
echo "🧱 啟用 iptables-services..."
systemctl enable iptables
systemctl start iptables

# 10. 設定基本 iptables 防火牆規則
echo "🛠️ 設定基本 iptables 防火牆規則..."
iptables -F
iptables -t nat -F
iptables -t nat -N DOCKER
iptables -N DOCKER
iptables -N DOCKER-ISOLATION-STAGE-1
iptables -N DOCKER-ISOLATION-STAGE-2
iptables -N DOCKER-USER
iptables -P FORWARD DROP

iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
#iptables -A INPUT -p tcp -m set --match-set ssh-whitelist src -m state --state NEW -m tcp --dport 33306 -j ACCEPT
#iptables -A INPUT -p tcp -m set --match-set ssh-whitelist src -m state --state NEW -m tcp --dport 36888 -j ACCEPT
#iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 36888 -j ACCEPT
iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited


echo "💾 儲存 iptables 規則"
service iptables save

echo "✅ 第二階段部署完成"
