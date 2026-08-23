#!/bin/bash

mkdir -p ./rules/site
mkdir -p ./rules/ip

# cn
cn_site_1="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/refs/heads/master/accelerated-domains.china.conf"
cn_ip_1="https://github.com/17mon/china_ip_list/raw/refs/heads/master/china_ip_list.txt"
cn_ip_2="https://github.com/metowolf/iplist/raw/refs/heads/master/data/special/china.txt"
cn_ip_3="https://ispip.clang.cn/all_cn.txt"
cn_ip_4="https://ispip.clang.cn/all_cn_ipv6.txt"
cn_ip_5="https://github.com/gaoyifan/china-operator-ip/raw/refs/heads/ip-lists/china46.txt"

cn_site=$(mktemp)
curl -fsSL "$cn_site_1" | cut -d'/' -f2 | sed 's/^/+./' | sort -u > "$cn_site"
mihomo convert-ruleset domain text $cn_site ./rules/site/cn.mrs && echo cn site done

cn_ip=$(mktemp)
cidr-merger -s -o $cn_ip < <(for url in $cn_ip_1 $cn_ip_2 $cn_ip_3 $cn_ip_4 $cn_ip_5; do
    curl -fsSL "$url"
    echo
done)
mihomo convert-ruleset ipcidr text $cn_ip ./rules/ip/cn.mrs && echo cn ip done

# !cn
us_ip_1="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geoip/us.list"
gb_ip_1="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geoip/gb.list"
fr_ip_1="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geoip/fr.list"
de_ip_1="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geoip/de.list"
ru_ip_1="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geoip/ru.list"
au_ip_1="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geoip/au.list"
jp_ip_1="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geoip/jp.list"
kr_ip_1="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geoip/kr.list"
sg_ip_1="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geoip/sg.list"

not_cn_ip=$(mktemp)
cidr-merger -s -o $not_cn_ip < <(for url in $us_ip_1 $gb_ip_1 $fr_ip_1 $de_ip_1 $ru_ip_1 $au_ip_1 $jp_ip_1 $kr_ip_1 $sg_ip_1; do
    curl -fsSL "$url"
    echo
done)
mihomo convert-ruleset ipcidr text $not_cn_ip ./rules/ip/!cn.mrs && echo !cn ip done

# httpdns
httpdns_and_1="https://github.com/QingRex/LoonKissSurge/raw/refs/heads/main/Surge/Beta/HTTPDNS拦截器.beta.sgmodule"
httpdns_and_2="https://github.com/QingRex/LoonKissSurge/raw/refs/heads/main/Surge/Official/拦截HTTPDNS.official.sgmodule"

httpdns_site=$(mktemp)
for url in $httpdns_and_1 $httpdns_and_2; do
    curl -fsSL "$url" | grep -E "^DOMAIN," | cut -d',' -f2 | sort -u
    echo
done > $httpdns_site
mihomo convert-ruleset domain text $httpdns_site ./rules/site/httpdns.mrs && echo httpdns site done

httpdns_ip=$(mktemp)
cidr-merger -s -o $httpdns_ip < <(for url in $httpdns_and_1 $httpdns_and_2; do
    curl -fsSL "$url" | grep -E "^IP-CIDR," | cut -d',' -f2
    echo
done)
mihomo convert-ruleset ipcidr text $httpdns_ip ./rules/ip/httpdns.mrs && echo httpdns ip done

# webrtc
webrtc_site_1="https://github.com/pradt2/always-online-stun/raw/refs/heads/master/valid_hosts.txt"
webrtc_site_2="https://github.com/pradt2/always-online-stun/raw/refs/heads/master/valid_hosts_tcp.txt"
webrtc_ip_1="https://github.com/pradt2/always-online-stun/raw/refs/heads/master/valid_ipv4s.txt"
webrtc_ip_2="https://github.com/pradt2/always-online-stun/raw/refs/heads/master/valid_ipv4s_tcp.txt"
webrtc_ip_3="https://github.com/pradt2/always-online-stun/raw/refs/heads/master/valid_ipv6s.txt"
webrtc_ip_4="https://github.com/pradt2/always-online-stun/raw/refs/heads/master/valid_ipv6s_tcp.txt"

webrtc_site=$(mktemp)
for url in $webrtc_site_1 $webrtc_site_2; do
    curl -fsSL "$url" | cut -d':' -f1 | sort -u
    echo
done > $webrtc_site
mihomo convert-ruleset domain text $webrtc_site ./rules/site/webrtc.mrs && echo webrtc site done

webrtc_ip=$(mktemp)
cidr-merger -s -o $webrtc_ip < <(for url in $webrtc_ip_1 $webrtc_ip_2 $webrtc_ip_3 $webrtc_ip_4; do
    curl -fsSL "$url" | sed -E 's/^\[([^]]+)\].*/\1\/128/; t; s/^([^:]+):.*/\1\/32/'
    echo
done)
mihomo convert-ruleset ipcidr text $webrtc_ip ./rules/ip/webrtc.mrs && echo webrtc ip done


