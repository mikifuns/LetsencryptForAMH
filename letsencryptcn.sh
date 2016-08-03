#!/bin/bash

# Usage: /etc/nginx/certs/letsencrypt.sh /etc/nginx/certs/letsencrypt.conf

CONFIG=$1
ACME_TINY="/tmp/acme_tiny.py"
DOMAIN_KEY=""

if [ -f "$CONFIG" ];then
    . "$CONFIG"
    DIRNAME=$(dirname "$CONFIG")
    cd "$DIRNAME" || exit 1
else
    echo "设置文件错误."
	echo  "获得更多信息,请访问http://mikifuns.com 或QQ:2306285095(仅限休息时间)"
    exit 1
fi

KEY_PREFIX="${DOMAIN_KEY%%.*}"
DOMAIN_CRT="$KEY_PREFIX.crt"
DOMAIN_PEM="$KEY_PREFIX.pem"
DOMAIN_CSR="$KEY_PREFIX.csr"
DOMAIN_CHAINED_CRT="$KEY_PREFIX.chained.crt"

if [ ! -f "$ACCOUNT_KEY" ];then
    echo "获取账户KEY中..."
    openssl genrsa 4096 > "$ACCOUNT_KEY"
fi

if [ ! -f "$DOMAIN_KEY" ];then
    echo "创建域名KEY..."
    if [ "$ECC" = "TRUE" ];then
        openssl ecparam -genkey -name secp256r1 | openssl ec -out "$DOMAIN_KEY"
    else
        openssl genrsa 2048 > "$DOMAIN_KEY"
    fi
fi

echo "创建CSR中...$DOMAIN_CSR"

OPENSSL_CONF="/etc/ssl/openssl.cnf"

if [ ! -f "$OPENSSL_CONF" ];then
    OPENSSL_CONF="/etc/pki/tls/openssl.cnf"
    if [ ! -f "$OPENSSL_CONF" ];then
        echo "错误,文件openssl.cnf未找到."
		echo  "获得更多信息,请访问http://mikifuns.com 或QQ:2306285095(仅限休息时间)"
        exit 1
    fi
fi

openssl req -new -sha256 -key "$DOMAIN_KEY" -subj "/" -reqexts SAN -config <(cat $OPENSSL_CONF <(printf "[SAN]\nsubjectAltName=%s" "$DOMAINS")) > "$DOMAIN_CSR"

wget https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py -O $ACME_TINY -o /dev/null

if [ -f "$DOMAIN_CRT" ];then
    mv "$DOMAIN_CRT" "$DOMAIN_CRT-OLD-$(date +%y%m%d-%H%M%S)"
fi

DOMAIN_DIR="$DOMAIN_DIR/.well-known/acme-challenge/"
mkdir -p "$DOMAIN_DIR"

python $ACME_TINY --account-key "$ACCOUNT_KEY" --csr "$DOMAIN_CSR" --acme-dir "$DOMAIN_DIR" > "$DOMAIN_CRT"

if [ "$?" != 0 ];then
    exit 1
fi

if [ ! -f "lets-encrypt-x3-cross-signed.pem" ];then
    wget https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem -o /dev/null
fi

cat "$DOMAIN_CRT" lets-encrypt-x3-cross-signed.pem > "$DOMAIN_CHAINED_CRT"

if [ "$LIGHTTPD" = "TRUE" ];then
    cat "$DOMAIN_KEY" "$DOMAIN_CRT" > "$DOMAIN_PEM"
    echo -e "\e[01;32m新 pem文件: $DOMAIN_PEM 已经创建\e[0m"
fi

echo -e "\e[01;32m新证书: $DOMAIN_CHAINED_CRT 已经被创建\e[0m"

#service nginx reload
