#!/usr/bin/env bash
# GitHub Actions 节点抓取脚本(跨平台, 不依赖 PowerShell)
# 抓取各源 v2ray 链接 -> 去重 -> 写 nodes.txt / nodes_base64.txt
set -uo pipefail

UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/126 Safari/537.36 MahsaFetch/1.0'
DIR="$(pwd)"                      # CI 里 checkout 后即仓库根; 本地运行时请 cd 到仓库再执行
TMP="$DIR/.tmp_src"
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT

# 源列表(与 config.json 一致; Actions runner 在海外, 直连即可, 不需要镜像)
SOURCES=(
  "VinoosIr_TG=https://raw.githubusercontent.com/VinoosIr/TelegramV2rayCollector/main/api/normal"
  "Kwinshadow_mix=https://raw.githubusercontent.com/Kwinshadow/TelegramV2rayCollector/main/sublinks/mix.txt"
  "0xRadikal_verified=https://raw.githubusercontent.com/0xRadikal/Free-v2ray-Configs/main/verified/configs.txt"
  "Alirewa_config=https://raw.githubusercontent.com/Alirewa/V2ray-Configs/main/config.txt"
  "Au1rxx_b64=https://raw.githubusercontent.com/Au1rxx/free-vpn-subscriptions/main/output/v2ray-base64.txt"
  "Epodonios_250=https://raw.githubusercontent.com/Epodonios/v2ray-configs/refs/heads/main/Sub1.txt"
)

> "$TMP/total.txt"
STATUS=0
for entry in "${SOURCES[@]}"; do
  name="${entry%%=*}"
  url="${entry#*=}"
  out="$TMP/$name"
  code=$(curl -sSL --max-time 40 -A "$UA" -o "$out" -w '%{http_code}' "$url" 2>/dev/null || true)
  if [ "$code" = "200" ] && [ -s "$out" ]; then
    cat "$out" >> "$TMP/total.txt"
    echo "[$code] $name ok ($(wc -c < "$out") B)"
  else
    echo "[$code] $name FAILED"
    STATUS=1
  fi
done
echo "--- 全部源抓取完成 (最低有一个成功即继续) ---"

# 提取 v2ray 链接并去重(保持顺序)
grep -aoE '(vmess|vless|trojan|ss|socks|hysteria2|hy2|tuic|wireguard|warp)://[^[:space:]"'"'"'<>]+' "$TMP/total.txt" 2>/dev/null \
  | sed -E 's/[;,)\]}]+$//' \
  | awk '!seen[$0]++' > nodes.txt

# base64 标准订阅
if [ -s nodes.txt ]; then
  base64 -w0 nodes.txt > nodes_base64.txt
  echo "nodes.txt: $(wc -l < nodes.txt) links"
  echo "nodes_base64.txt: $(wc -c < nodes_base64.txt) B"
else
  echo "!! 0 节点, 保留旧文件不覆盖"
  exit 0
fi

if [ "$STATUS" != "0" ]; then
  echo "注意: 部分源失败, 但已成功抓取到节点, 照常更新"
fi