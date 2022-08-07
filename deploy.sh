#!/bin/sh

# exit if systemd is not avaliable
[ ! -d /run/systemd/system ] && echo "OS not supported! Exit" && exit 0

deploy_server() {
    echo "deploying server..."
    curl 'https://ghproxy.com/https://raw.githubusercontent.com/marsbasex/tunnel/master/frps' -o /usr/bin/frps
    chmod a+x /usr/bin/frps
    cat > /usr/lib/systemd/system/frps.service <<EOF
[Unit]
Description=frps
After=network.target

[Service]
ExecStart=/usr/bin/frps --disable_log_color --bind_port 7000 --token 'TCD_wtz1amh9xea0rub' --dashboard_port 7001 --dashboard_pwd 'TCD_wtz1amh9xea0rub' --allow_ports 18000-19000
Type=simple
User=nobody
KillMode=process
RestartSec=5s
Restart=on-failure
RestartPreventExitStatus=255

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl start frps
    systemctl enable frps
    systemctl status frps --no-pager
}

deploy_client() {
    echo "deploying client..."
    server_ip=$1
    echo "server ip: $server_ip"
    curl 'https://ghproxy.com/https://raw.githubusercontent.com/marsbasex/tunnel/master/frpc' -o /usr/bin/frpc
    chmod a+x /usr/bin/frpc
    cat > /usr/lib/systemd/system/frpc.service <<EOF
[Unit]
Description=frpc
After=network.target

[Service]
ExecStart=/usr/bin/frpc tcp --disable_log_color --token 'TCD_wtz1amh9xea0rub' --local_port 18080 --remote_port 18080 --server_addr #server_ip#:7000
Type=simple
User=nobody
KillMode=process
RestartSec=5s
Restart=on-failure
RestartPreventExitStatus=255

[Install]
WantedBy=multi-user.target
EOF
    sed -i "s/#server_ip#/$server_ip/" /usr/lib/systemd/system/frpc.service
    systemctl daemon-reload
    systemctl start frpc
    systemctl enable frpc
    systemctl status frpc --no-pager
}

check_server() {
    echo "checking server..."
    server_ip=$1
    echo "server ip: $server_ip"
    nc -vz -w 3 $server_ip 7000
    nc -vz -w 3 $server_ip 7001
}

if [ $# -eq 0 ]; then
    echo './deploy --server [To deploy server. Make sure port 7000,7001,18080 is available]'
    echo '         --client $server_ip [To deploy client]'
    echo '         --check  $server_ip [To check ports 7000,7001 of server is accessible]'
elif [ $1 = "--server" ]; then
    deploy_server
elif [ $1 = "--client" ]; then
    deploy_client $2
elif [ $1 = "--check" ]; then
    check_server $2
fi
