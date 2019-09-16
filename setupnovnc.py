import os
import textwrap


def install_systemd_service(command, servicename):
    """
        Creates a new service called <servicename>.service and start it
    """
    systemd_unitfile = f"""[Unit]
                           Description=Run {command}

                           [Service]
                           Type=exec
                           ExecStart={command}
                           ExecReload=/bin/kill -1 -- $MAINPID
                           ExecStop=/bin/kill -- $MAINPID
                           KillMode=mixed

                           [Install]
                           WantedBy=multi-user.target"""
    systemd_unitfile = textwrap.dedent(systemd_unitfile)
    systemd_unit_path = f"/etc/systemd/system/{servicename}.service"
    with open(systemd_unit_path, "w") as f:
        f.write(systemd_unitfile)
    os.chmod(systemd_unit_path, 0o644)
    os.system("systemctl daemon-reload")
    os.system(f"systemctl enable {servicename}.service --now")


os.system("(apt-get update || true) && "
          "apt-get install -y vnc4server")
os.system('echo "password" | vncpasswd -f > /opt/pass-file')
install_systemd_service("/usr/bin/x0vncserver -PasswordFile /opt/pass-file",
                        "vnc")

os.system("git clone https://github.com/novnc/noVNC.git /opt/noVNC")

install_systemd_service("/opt/noVNC/utils/launch.sh --vnc localhost:5900", 
                        "noVNC")



