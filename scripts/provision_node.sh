#!/usr/bin/env bash
set -euo pipefail

if [[ $(id -u) -ne 0 ]]; then
  echo "Run this script as root" >&2
  exit 1
fi

node=${1:?node number is required}

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y full-upgrade
if [[ -f /usr/bin/pkexec ]]; then
  chmod 0755 /usr/bin/pkexec
fi

case "$node" in
  1) user=user1; password=user1; challenge=find; url=https://gtfobins.github.io/gtfobins/find/ ;;
  2) user=user2; password=A7kP3xQ8nZ1wR5L6; challenge=tar; url=https://gtfobins.github.io/gtfobins/tar/ ;;
  3) user=user3; password=C9mN4tV2pH7sJ5dE; challenge=vim; url=https://gtfobins.github.io/gtfobins/vim/ ;;
  4) user=user4; password=Q1w2E3r4T5y6U7i8; challenge=less; url=https://gtfobins.github.io/gtfobins/less/ ;;
  5) user=user5; password=R8nT2pL6sV4yQ1wZ; challenge=awk; url=https://gtfobins.github.io/gtfobins/awk/ ;;
  6) user=user6; password=S3u7Yp9Lw2Hq4V8X; challenge=python3; url=https://gtfobins.github.io/gtfobins/python/ ;;
  7) user=user7; password=T8r5Qw1La3Ns7V9K; challenge=python-capability; url=https://gtfobins.github.io/gtfobins/python/ ;;
  8) user=user8; password=U2y6Pf4Ka8Md1S3Z; challenge=bash-suid; url=https://gtfobins.github.io/gtfobins/bash/ ;;
  9) user=user9; password=V5t1Hg7Lc2Nb4Q8X; challenge=cron; url=https://gtfobins.github.io/gtfobins/bash/ ;;
  10) user=user10; password=W7p3Xc5Zl9Ty2R4M; challenge=systemd; url=https://gtfobins.github.io/gtfobins/bash/ ;;
  11) user=user11; password=X1s4Dv6Fq8Gh0P2B; challenge=rsync; url=https://gtfobins.github.io/gtfobins/rsync/ ;;
  *) echo "Unsupported node: $node" >&2; exit 1 ;;
esac

if ! id "$user" &>/dev/null; then
  useradd -m -s /bin/bash "$user"
fi
echo "$user:$password" | chpasswd

cat > /etc/ssh/sshd_config.d/99-pwnable-passwords.conf <<'EOF'
PasswordAuthentication yes
EOF
systemctl restart ssh

cat > "/home/$user/README.txt" <<EOF
Challenge reference:
$url
EOF
chown "$user:$user" "/home/$user/README.txt"
chmod 0644 "/home/$user/README.txt"

install_sudo_rule() {
  local binary=$1
  cat > "/etc/sudoers.d/$user" <<EOF
$user ALL=(root) NOPASSWD: $binary *
EOF
  chmod 0440 "/etc/sudoers.d/$user"
  visudo -cf "/etc/sudoers.d/$user"
}

case "$challenge" in
  find) install_sudo_rule /usr/bin/find ;;
  tar) install_sudo_rule /usr/bin/tar ;;
  vim)
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get -y install vim
    install_sudo_rule /usr/bin/vim
    ;;
  less)
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get -y install less
    install_sudo_rule /usr/bin/less
    ;;
  awk) install_sudo_rule /usr/bin/awk ;;
  python3) install_sudo_rule /usr/bin/python3 ;;
  python-capability)
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get -y install libcap2-bin
    setcap cap_setuid+ep "$(readlink -f /usr/bin/python3)"
    ;;
  bash-suid) chmod 4755 /usr/bin/bash ;;
  cron)
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get -y install cron
    cat > /opt/maintenance.sh <<'EOF'
#!/usr/bin/env bash
date >> /var/log/pwnable-maintenance.log
EOF
    chown root:"$user" /opt/maintenance.sh
    chmod 0775 /opt/maintenance.sh
    cat > /etc/cron.d/pwnable-maintenance <<EOF
* * * * * root /opt/maintenance.sh
EOF
    chmod 0644 /etc/cron.d/pwnable-maintenance
    systemctl enable --now cron
    ;;
  systemd)
    cat > /opt/report.sh <<'EOF'
#!/usr/bin/env bash
date >> /var/log/pwnable-report.log
EOF
    chown root:"$user" /opt/report.sh
    chmod 0775 /opt/report.sh
    cat > /etc/systemd/system/pwnable-report.service <<'EOF'
[Unit]
Description=Pwnable report task

[Service]
Type=oneshot
ExecStart=/opt/report.sh
EOF
    cat > /etc/systemd/system/pwnable-report.timer <<'EOF'
[Unit]
Description=Run the pwnable report task

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
Unit=pwnable-report.service

[Install]
WantedBy=timers.target
EOF
    systemctl daemon-reload
    systemctl enable --now pwnable-report.timer
    ;;
  rsync)
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get -y install rsync
    install_sudo_rule /usr/bin/rsync
    ;;
esac

if [[ "$node" -lt 11 ]]; then
  next_node=$((node + 1))
  next_ip="192.168.56.$((10 + next_node))"
  next_user="user$next_node"
  next_password=$(case "$next_node" in
    2) printf '%s' A7kP3xQ8nZ1wR5L6 ;;
    3) printf '%s' C9mN4tV2pH7sJ5dE ;;
    4) printf '%s' Q1w2E3r4T5y6U7i8 ;;
    5) printf '%s' R8nT2pL6sV4yQ1wZ ;;
    6) printf '%s' S3u7Yp9Lw2Hq4V8X ;;
    7) printf '%s' T8r5Qw1La3Ns7V9K ;;
    8) printf '%s' U2y6Pf4Ka8Md1S3Z ;;
    9) printf '%s' V5t1Hg7Lc2Nb4Q8X ;;
    10) printf '%s' W7p3Xc5Zl9Ty2R4M ;;
    11) printf '%s' X1s4Dv6Fq8Gh0P2B ;;
  esac)
  cat > /root/user.txt <<EOF
Congrats, you reached root using "$challenge".
Now SSH to $next_user@$next_ip with password "$next_password" to continue.
EOF
else
  cat > /root/user.txt <<'EOF'
Congratulations, you completed the lab. Please star the repository so more people can find it.
EOF
fi
chmod 0600 /root/user.txt

# Vagrant needs its bootstrap privileges only while this provisioner runs.
gpasswd -d vagrant sudo 2>/dev/null || true
rm -f /etc/sudoers.d/vagrant
