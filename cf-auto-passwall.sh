# ... 脚本前面的变量定义保持不变 ...

while true
do
    echo "正在从 wetest.vip 提取电信优选节点..."
    
    # 精准提取：定位到“电信”字样，取其后第一个符合 IP 规则的字符串
    anycast=$(curl -s --connect-timeout 10 https://www.wetest.vip/page/cloudflare/address_v4.html | \
        sed -n '/电信/,/<\/tr>/p' | \
        grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | \
        head -n 1)

    if [ -z "$anycast" ]; then
        echo "获取失败，5秒后重试..."
        sleep 5
        continue
    fi

    echo "成功获取 IP: $anycast ，开始进行 PassWall 更新..."
    
    # 直接跳转到原脚本的更新逻辑
    uci set passwall.xxxxxxxxxx.address=$anycast
    uci commit passwall
    /etc/init.d/haproxy restart
    /etc/init.d/passwall restart
    
    echo "更新完成！"
    break
done
