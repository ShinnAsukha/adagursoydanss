$iptables -N BotKoruma
$iptables -F BotKoruma
$iptables -A BotKoruma -p tcp --dport $port -m set --match-set proxies src -j DROP
$iptables -A BotKoruma -p tcp --dport $port -m set --match-set whitelist src -j ACCEPT
$iptables -A BotKoruma -p tcp --dport $port --syn -m limit --limit $burstconns/s -j ACCEPT
$iptables -A BotKoruma -p tcp --dport $port --syn -j DROP
$iptables -D INPUT -p tcp -j BotKoruma
$iptables -A INPUT -p tcp -j BotKoruma
$iptables -A INPUT -p tcp -m tcp --syn --tcp-option 8 --dport 25565 -j REJECT
$iptables -I INPUT -p tcp -s 149.202.74.183 -j ACCEPT
$iptables -I OUTPUT -p tcp -d 149.202.74.183 -j ACCEPT
$iptables -I INPUT -p tcp -s 178.32.62.55 -j ACCEPT
$iptables -I OUTPUT -p tcp -d 178.32.62.55 -j ACCEPT
$iptables -I INPUT -p tcp -s 37.187.63.146 -j ACCEPT
$iptables -I OUTPUT -p tcp -d 37.187.63.146 -j ACCEPT
$iptables -I INPUT -p tcp -s 92.222.160.58 -j ACCEPT
$iptables -I INPUT -p tcp -s 5.196.10.200 -j ACCEPT
$iptables -I OUTPUT -p tcp -d 5.196.10.200 -j ACCEPT
$iptables -I OUTPUT -p tcp -d 92.222.160.58 -j ACCEPT
$iptables -A INPUT -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
$iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN -j DROP
$iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,PSH,URG -j DROP
$iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -j DROP
$iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
$iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
$iptables -A OUTPUT -p udp -j DROP
$ip6tables -A OUTPUT -p udp -j DROP
$iptables -A INPUT -p tcp --destination-port 8080 -j DROP
$iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
$iptables -A INPUT -p tcp --tcp-flags SYN,ECN,CWR -j DROP
if $block_linux_connections ; then
    $$iptables -A INPUT -p tcp -m tcp --syn --tcp-option 8 --dport $port -j REJECT
    echo 'Linux bağlantıları engellendi!'
fi

if $limit_global_connections ; then
    $iptables -I INPUT -p tcp --dport $port -m state --state NEW -m limit --limit $limit_global_connections_max/s -j ACCEPT
    echo 'Global bağlantılar limitlendi!'
fi

echo "Firewall kurulumu tammalandı."