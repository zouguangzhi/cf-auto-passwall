#!/bin/sh

# ================= 配置区 =================
# 请将下方的 xxxxxxxxxx 替换为你 PassWall 真实的节点 ID
# 你可以在终端输入 uci show passwall 来查询 ID
NODE_ID="xxxxxxxxxx"
# ==========================================

echo "正在从 wetest.vip 提取优选 IP..."

# 执行抓取命令：抓取 -> 提取IP -> 排序去重 -> 取第一个
anycast=$(curl -s https://www.wetest.vip/page/cloudflare/address_v4.html | \
          grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | \
          sort -u | head -n 1)

# 检查是否成功获取到 IP
if [ -z "$anycast" ]; then
    echo "错误：无法获取 IP 地址，请检查网络或网页链接。"
    exit 1
fi

echo "成功获取 IP: $anycast ，开始进行 PassWall 更新..."

# 获取当前配置中的 IP，用于对比
old_ip=$(uci get passwall.$NODE_ID.address 2>/dev/null)

if [ "$old_ip" = "$anycast" ]; then
    echo "当前 IP ($old_ip) 已是最新，无需更新。"
    exit 0
fi

# 执行 uci 替换逻辑
uci set passwall.$NODE_ID.address=$anycast
uci commit passwall

echo "配置已修改，正在重启服务..."

# 重启相关服务
/etc/init.d/haproxy restart
/etc/init.d/passwall restart

echo "更新完成！新 IP 为: $anycast"
