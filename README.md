# v2ray-sub

自动聚合更新的 v2ray/vless/trojan 免费节点订阅仓库,由 GitHub Actions 每 6 小时自动抓取源并更新。

## 订阅地址

v2rayN / Clash 等客户端在"订阅"里添加以下地址即可:

```
https://raw.githubusercontent.com/szhsh2011-jpg/v2ray-sub/main/nodes_base64.txt
```

加速镜像(可选,国内访问更快):

```
https://gh-proxy.com/https://raw.githubusercontent.com/szhsh2011-jpg/v2ray-sub/main/nodes_base64.txt
```

## 使用方式(v2rayN)

1. 打开 v2rayN → 订阅分组 → 添加订阅
2. URL 填上面的地址 → 保存
3. 右键订阅 → 更新订阅
4. 之后每次更新都从 GitHub 拉最新集合, 任意设备可用

## 目录结构

- `nodes.txt` 纯文本 v2ray 链接(每行一个)
- `nodes_base64.txt` 标准 base64 订阅(主流客户端通用)
- `fetch.sh` 抓取脚本(GitHub Actions 调用)
- `.github/workflows/update-nodes.yml` 每 6 小时自动更新配置

## 手动触发更新

仓库 Actions 页面 → "Update Nodes" → Run workflow。

## 说明

- 免费节点来源多、质量参差, 更新后需自行测速筛选。
- 仅作技术学习用途, 请遵守当地法律法规。