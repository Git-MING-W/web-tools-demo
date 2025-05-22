#!/bin/bash

# 检查参数是否存在
if [ -z "$1" ]; then
  echo "使用方法: $0 <域名>"
  echo "例如: $0 hyz123.com"
  exit 1
fi

DOMAIN=$1

# 执行docker run命令
docker run -it \
  --network=host \
  --dns 8.8.8.8 --dns 1.1.1.1 \
  -v /etc/nginx/certificates:/etc/letsencrypt \
  -v /etc/nginx/certbot:/var/www/certbot \
  certbot/certbot certonly --webroot \
  -w /var/www/certbot \
  -d "$DOMAIN"