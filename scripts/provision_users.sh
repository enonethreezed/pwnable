#!/usr/bin/env bash
set -euo pipefail

fixed_users=("user1:user1")
random_users=(user2 user3 user4 user5 user6 user7 user8 user9 user10 user11 user12 user0)
passfile=/root/ctf-users.txt
: > "$passfile"
chmod 600 "$passfile"

for pair in "${fixed_users[@]}"; do
  IFS=":" read -r user pass <<<"$pair"
  if ! id "$user" &>/dev/null; then
    useradd -m -s /bin/bash "$user"
  fi
  echo "$user:$pass" | chpasswd
  echo "$user:$pass" >> "$passfile"
done

generate_pass() {
  python3 - <<'PY'
import secrets
alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
print(''.join(secrets.choice(alphabet) for _ in range(16)), end='')
PY
}

for user in "${random_users[@]}"; do
  pass=$(generate_pass)
  if ! id "$user" &>/dev/null; then
    useradd -m -s /bin/bash "$user"
  fi
  echo "$user:$pass" | chpasswd
  echo "$user:$pass" >> "$passfile"
done

chown root:root "$passfile"
