#!/bin/bash

git clone https://github.com/novnc/noVNC.git /opt/noVNC

(
cat <<'EOF'
[Unit]
Description=Browser based remote desktop service
After=syslog.target network.target

[Service]
Type=simple
ExecStart=/opt/noVNC/utils/launch.sh --vnc localhost:5901
ExecReload=/bin/kill -1 -- $MAINPID
ExecStop=/bin/kill -- $MAINPID
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF
) > /etc/systemd/system/noVNC.service

systemctl daemon-reload
systemctl enable noVNC.service --now

