# Pwnable CTF

## Overview
This CTF revolves around a Vagrant-provisioned Ubuntu machine that contains a long chain of local privilege escalations. Each user leaves small notes behind that reflect their habits, nudging the next player toward the intended technique. The ultimate goal is to keep hopping from account to account until you gain root.

## Flujo de retos
1. **user1 → user2**  
   Classic filesystem enumeration. Find the file owned by group `user2` (`/var/tmp/secret.txt`) and decode it following the hints in `~/user2.txt` (reverse → ROT13 → Base64).

2. **user2 → user3**  
   Cron triggers `/opt/backup_user3.sh` every five minutes, and both that script and `/opt/backup/include.list` are writable by group `backupops`. Edit the script (or list) to piggyback a command that copies `/home/user3/secret.txt` into a location you control.

3. **user3 → user4**  
   user4 built a bespoke SUID binary in C (`/usr/local/bin/u4view`, owned by user4:group user3). It’s the “official” tool to list or read his home directory (`u4view -d /home/user4`, `u4view -f ...`). Running it exposes user4’s secret.

4. **user4 → user5**  
   user5’s workflow lives under `/opt/user5/` and runs via a system-level `systemd` timer. The script `note_sync.sh` is group-owned by `syncshare`, so edit it to append your own exfiltration command (for example, copy `/home/user5/secret.txt` into `/tmp/user5_secret`) and wait for the timer to kick in. Each run also drops an empty `/tmp/user5_service_ok` (mode `0600`), which doubles as a heartbeat to confirm your changes executed.

5. **user5 → user6**  
   `/usr/local/bin/u6awk` (SUID, group user5) is user6’s gift. Instead of spawning a shell, use the GTFOBins read primitive: set `LFILE=/home/user6/secret.txt` and run `u6awk '//' "$LFILE"` to dump the password.

6. **user6 → user7**  
   user6 can run `sudo /usr/local/bin/u7-find` as user7. Abuse GTFOBins by invoking `sudo -u user7 /usr/local/bin/u7-find . -exec /bin/sh \; -quit` to pop a shell and read `/home/user7/secret.txt`.

7. **user7 → user8**  
   `/usr/local/bin/u8-view` launches `less` as user8. Use it to open `/home/user8/secret.txt` (e.g., `:e /home/user8/secret.txt`) and then authenticate as user8.

8. **user8 → user9**  
   user8 enjoys password-less sudo for `python3 /opt/user9/maintenance.py`. The script lives in `/opt/user9/` and is editable by the shared `maintops` group, so tweak the script to print or copy `/home/user9/secret.txt`, then run the sudo command to execute it as user9.

9. **user9 → user10**  
   `sudo -u user10 /usr/bin/tar -cf /tmp/backup.tar *` is allowed. Append `--checkpoint=1 --checkpoint-action=exec=/bin/bash` (per GTFOBins) to spawn a shell as user10.

10. **user10 → user11**  
    `/usr/local/bin/u11-cat` is a SUID `cat` owned by user11. Run `u11-cat /home/user11/secret.txt` to read the credential.

11. **user11 → user12**  
    `sudo /usr/bin/vim /var/log/app/user12.log` is permitted. Escape from Vim (`:!bash`, `:e /home/user12/secret.txt`, etc.) to impersonate user12.

12. **user12 → root**  
    The SUID binary `nmap520` keeps the vulnerable `--interactive` console from Nmap 5.20. Run `nmap520 --interactive`, type `!sh`, and you get a UID 0 shell.

Each phase combines a bit of narrative with a hands-on exploitation technique, encouraging players to observe, enumerate, and improvise their way up the chain without explicit spoilers.
