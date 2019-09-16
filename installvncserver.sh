#!/bin/bash

VNCUSER="root"
apt-get update
apt-get install -y vnc4server tigervnc-common tigervnc-standalone-server
echo "password" | vncpasswd -f > /opt/pass-file
xhost +si:localuser:root

(
cat <<'EOF'
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=simple
User=foo
PAMName=login
PIDFile=/home/%u/.vnc/%H%i.pid
ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || :'
ExecStart=/usr/bin/vncserver %i -geometry 1440x900 -alwaysshared -fg
ExecStop=/usr/bin/vncserver -kill %i

[Install]
WantedBy=multi-user.target
EOF
) > /etc/systemd/system/vncserver@:1.service


systemctl daemon-reload
systemctl enable vncserver@:1.service --now
