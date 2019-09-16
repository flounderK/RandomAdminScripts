#!/bin/bash

apt install -y python-numpy
git clone https://github.com/novnc/noVNC.git /opt/noVNC
(
cat <<'EOF'
US
Ohio
Cincinnati
Cyber@UC


EOF
) | openssl req -x509 -nodes -newkey rsa:2048 -keyout novnc.pem -out novnc.pem -days 365
chmod 644 novnc.pem

(
cat <<'EOF'
[Unit]
Description=Browser based remote desktop service
After=syslog.target network.target

[Service]
Type=exec
ExecStart=/opt/noVNC/utils/launch.sh --vnc localhost:5901
ExecReload=/bin/kill -1 -- $MAINPID
ExecStop=/bin/kill -- $MAINPID
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
) > /etc/systemd/system/noVNC.service

systemctl daemon-reload
systemctl enable noVNC.service --now

