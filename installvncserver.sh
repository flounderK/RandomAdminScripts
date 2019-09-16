#!/bin/bash

VNCUSER="user"
# useradd -m $VNCUSER
mkdir -p /home/$VNCUSER/.vnc
touch /home/$VNCUSER/.Xauthority
chmod +x /home/$VNCUSER/.Xauthority
chown $VNCUSER:$VNCUSER /home/$VNCUSER/.Xauthority


(
cat <<EOF
#!/bin/bash
export XKL_XMODMAP_DISABLE=1
# unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && exec $HOME/.Xresources
xsetroot -solid grey
vncconfig -iconic &
metacity &
startxfce4 &
EOF
) > /home/$VNCUSER/.vnc/xstartup
chmod +x /home/$VNCUSER/.vnc/xstartup

apt-get update
apt-get install -y vnc4server tigervnc-common tigervnc-standalone-server \
	 metacity nautilus xfce4-session xfce4-wmdock-plugin xfce4-terminal
echo "password" | vncpasswd -f > /home/$VNCUSER/.vnc/passwd
xhost +si:localuser:$VNCUSER

chown -R $VNCUSER:$VNCUSER /home/$VNCUSER/.vnc

(
cat <<EOF
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=simple
User=$VNCUSER
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
