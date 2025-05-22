#!/bin/bash

# ========== [參數檢查] ==========
usage() {
  echo "用法：bash $0 <domain> [nginx_conf_path]"
  echo "範例："
  echo "  bash $0 example.com /etc/nginx/conf.d/custom.conf"
  exit 1
}

# 檢查是否有傳入第一個參數（域名）
if [ -z "$1" ]; then
  echo "❌ 錯誤：缺少域名參數"
  usage
fi

DOMAIN="$1"

# 若指定第二個參數，檢查檔案是否存在
if [ -z "$2" ] || [ ! -f "$2" ]; then
    echo "❌ 錯誤：請指定有效的 Nginx 設定檔路徑"
    usage
else
  NGINX_CONF="$2"
fi

CERT_DIR="/etc/nginx/certificates"
CERTBOT_DIR="/etc/nginx/certbot"
CERT_DST="/etc/nginx/certs"
CERT_FULLCHAIN="$CERT_DIR/live/$DOMAIN/fullchain.pem"
CERT_PRIVKEY="$CERT_DIR/live/$DOMAIN/privkey.pem"

# ========== [建立所需目錄] ==========
mkdir -p "$CERTBOT_DIR"
mkdir -p "$CERT_DIR"
mkdir -p "$CERT_DST"

# ========== [Let's Encrypt 憑證申請] ==========
echo "🚀 嘗試申請 Let's Encrypt 憑證 for $DOMAIN..."
docker run --rm -it \
  --name certbot_temp \
  -v "$CERT_DIR":/etc/letsencrypt \
  -v "$CERTBOT_DIR":/var/www/certbot \
  certbot/certbot certonly --webroot \
  -w /var/www/certbot \
  -d "$DOMAIN"

# ========== [檢查憑證是否成功] ==========
if [[ -f "$CERT_FULLCHAIN" && -f "$CERT_PRIVKEY" ]]; then
  echo "✅ 成功取得 Let's Encrypt 憑證！"

  ln -sf "$CERT_FULLCHAIN" "$CERT_DST/$DOMAIN.crt"
  ln -sf "$CERT_PRIVKEY" "$CERT_DST/$DOMAIN.key"

else
  echo "⚠️ 無法取得 Let's Encrypt 憑證，使用自簽憑證..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$CERT_DST/$DOMAIN.key" \
    -out "$CERT_DST/$DOMAIN.crt" \
    -subj "/C=TW/ST=Taiwan/L=Taipei/O=Dev/OU=Test/CN=$DOMAIN"
  echo "✅ 自簽憑證已產生："
fi

# ========== [驗證憑證存在並替換 nginx.conf] ==========
if [[ -f "$CERT_DST/$DOMAIN.crt" && -f "$CERT_DST/$DOMAIN.key" ]]; then
  echo "🔗 憑證位置："
  echo "  - $CERT_DST/$DOMAIN.crt"
  echo "  - $CERT_DST/$DOMAIN.key"

  # 替換 nginx 設定中的 selfsigned 為實際域名
  sed -i "s/selfsigned/$DOMAIN/g" "$NGINX_CONF"
  echo "🛠 已更新 nginx 設定檔 [$NGINX_CONF] 中的憑證名稱為：$DOMAIN"
  
else
  echo "❌ SSL 建置失敗，請檢查是否成功建立或授權失敗"
  exit 1
fi

echo "✅ SSL 建置完成，請確認 nginx 設定後 reload"
