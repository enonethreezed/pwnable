# Pwnable VM Provisioning

## Base Environment
- Box: `bento/ubuntu-22.04` (version `202510.26.0`) running under VirtualBox via Vagrant.
- Resources: 2 GB RAM, 128 MB VRAM, GUI disabled (`vb.gui = false`).
- Hostname set to `pwnable00` with `hostnamectl set-hostname` so the change persists across boots.

## Access Model
- `user1`: password `user1`, SSH access currently reuses the same public key as `vagrant` (located in `/home/user1/.ssh/authorized_keys`). This key will be rotated/removed before release.
- `vagrant`: temporary bootstrap user with `NOPASSWD:ALL` rights defined in `/etc/sudoers.d/vagrant`. Account and sudo rule will be removed at the end of the build.

## Hardening & Findings
- LinPEAS has been executed from `user1` and stored at `/home/user1/linpeas.log` (ansi-free copy in `user1-linpeas.txt`). Latest run confirms `pkexec` is *not* SUID anymore (`-rwxr-xr-x`).
- `/usr/bin/pkexec` SUID bit removed to shrink the attack surface despite package `policykit-1` being patched (0.105-33).
- Host still reports unpatched kernel CVEs (DirtyPipe, CVE-2021-3156, CVE-2022-32250, etc.). Pending action: `apt update && apt full-upgrade`, reboot, and optionally disable `kernel.unprivileged_userns_clone`.
- LXD snap daemon is running; members of group `lxd` can escalate to root. Ensure no CTF user remains in `lxd` or uninstall the snap if not needed.
- `/etc/sudoers.d/vagrant` is world-readable by default. Before shipping, restrict permissions to `0440 root:root` or remove the file along with the user.
- `ufw` is enabled with default deny (incoming/outgoing). Loopback is permitted, and TCP/22 is the only allowed external ingress so contestants can SSH in; all other egress is blocked to keep the VM isolated.

## Outstanding Tasks Before Shipping the CTF VM
1. Remove `vagrant` account and its sudo entry.
2. Rotate/remove shared SSH keys (especially `user1` inheriting `vagrant`'s key).
3. Apply OS updates and reboot to load patched kernel/userspace.
4. Re-run LinPEAS or equivalent to capture a clean, post-hardening log.
5. Review remaining SUID/SGID binaries (`snap-confine`, `VBoxDRMClient`, etc.) and strip bits if not required for the challenge.
6. Reassess AppArmor/seccomp settings and enable enforcing profiles where possible.

## Validation
- Latest LinPEAS run: `/home/user1/linpeas.log` (execution as `user1`).
- `hostnamectl` output reflects `pwnable00`.
- `pkexec --version` reports `0.105` with permissions `0755`.

Keep this README updated as further provisioning steps are completed.

## Review Status
- Done: user12 → root validated, root secret created.

## Recent Changes
- `u8-view` now uses `chdir` + `execl` to keep user8 privileges for `less`.
- `/var/log/user8` and its log are group `user7` to allow the SUID flow to enter the directory.
- Added `maintops` group and group-writable `/opt/user9/maintenance.py` for the user8 → user9 step.
- Sudoers cleanup now preserves all challenge-specific drop-ins.

## User Provisioning & Maintenance Scripts
- Added `scripts/provision_users.sh` to (re)create `user1` … `user12` plus `user0` (future attacker role).
- Script ensures `user1` keeps password `user1` and generates random 16-character alphanumeric passwords (via `python3 -c "import secrets,string;print(''.join(secrets.choice(string.ascii_letters+string.digits) for _ in range(16)))"`) for the remaining users, applies them with `chpasswd`, and stores the pairs in `/root/ctf-users.txt` (mode `600`).
- Each user receives a home directory and `/bin/bash` shell; no sudo or extra groups assigned by default.
- To re-run: `sudo bash /vagrant/scripts/provision_users.sh` from inside the VM. Remove `/root/ctf-users.txt` or rotate passwords before publishing the challenge.
- Added `scripts/update_and_harden.sh` to run `apt-get update && full-upgrade` and enforce non-SUID permissions on `/usr/bin/pkexec`. Execute as root (`sudo bash /vagrant/scripts/update_and_harden.sh`) and reboot afterwards if the kernel was upgraded.
- `scripts/setup_challenge.sh` deploys the hint file, the `rot13.sh` helper, the encoded blob in `/var/tmp/secret.txt`, and all subsequent escalation mechanics (user3’s backup cron, the auxiliary `u4view` binary, user5’s `systemd --user` service, the SUID `awk`, etc.). It also purges every drop-in in `/etc/sudoers.d/` except the controlled `00-ctf-sudo` (which keeps privileges for `%sudo` only) and removes every CTF account from the sudo group. As a cosmetic touch, it installs `figlet`, generates the “Demencia Shell-nil” banner, and writes it both to `/home/vagrant/motd.txt` and `/etc/motd`. Finally, it wipes `/tmp/vagrant-shell` so no provisioner artifacts remain.

## Challenge Hooks
- User1 → User2: `/var/tmp/secret.txt` belongs to group `user2`, is world-readable, and contains the password for user2 (reverse → ROT13 → Base64). The cleartext is `A7kP3xQ8nZ1wR5L6`.
- user1 has `/home/user1/user2.txt` pointing to `man rev`, `/usr/local/bin/rot13.sh`, and `man base64` so the decoding path is obvious.
- User2 → User3: cron runs `/opt/backup_user3.sh` as user3, and both that script and `/opt/backup/include.list` are writable by group `backupops`. user2 simply edits the script (or the list) to inject a command such as copying `/home/user3/secret.txt` into `/tmp/user3_sync/secret.txt`. The hint sits in `/home/user2/user3.txt`.
- User3 → User4: `/usr/local/bin/u4view` is SUID user4 (mode `4770`, group `user3`). It lists and reads user4’s files even though `/home/user4` is `0700`. The note `/home/user3/user4.txt` explains how to use it (`u4view -d ...`, `u4view -f ...`) to retrieve `Q1w2E3r4T5y6U7i8`.
- User4 → User5: user5 keeps a system-level `systemd` service/timer pair (`user5-note-sync.service/.timer`) that calls `/opt/user5/bin/note_sync.sh` every couple of minutes. All payloads live under `/opt/user5/`, owned by group `syncshare`. With `/home/user5` set to `0750 syncshare`, user4 can edit the script to append arbitrary commands (e.g., copy `/home/user5/secret.txt` to `/tmp/user5_secret`). Each execution also recreates `/tmp/user5_service_ok` (mode `0600`) as a heartbeat. Wait for the timer or, once you have appropriate privileges, restart the service to recover `R8nT2pL6sV4yQ1wZ`. Hint: `/home/user4/user5.txt`.
- User5 → User6: `/usr/local/bin/u6awk` is a SUID copy of awk owned by user6 but group-readable by user5. Instead of aiming for a shell, use the GTFOBins read trick: set `LFILE` to the target and run `u6awk '//' "$LFILE"` to dump `/home/user6/secret.txt`, yielding `S3u7Yp9Lw2Hq4V8X`. Hint: `/home/user5/user6.txt`.
- User6 → User7: `sudo /usr/local/bin/u7-find` is allowed with user7’s privileges (defined in `/etc/sudoers.d/user6-u7-find`). Run `sudo -u user7 /usr/local/bin/u7-find . -exec /bin/sh \; -quit` (GTFOBins pattern) to hijack execution and read `/home/user7/secret.txt`.
- User7 → User8: `/usr/local/bin/u8-view` (user8:user7, `4750`) launches `less` as user8. Use `less` to read `/home/user8/secret.txt` directly (e.g., `:e /home/user8/secret.txt`) and then authenticate as user8. Hint: `/home/user7/user8.txt`.
- User8 → User9: `/etc/sudoers.d/user8-maint` grants `sudo /usr/bin/python3 /opt/user9/maintenance.py` with no password. The script and `/opt/user9` are group-writable by `maintops`, so user8 can edit the script to read `/home/user9/secret.txt`, then execute it via sudo. See `/home/user8/user9.txt`.
- User9 → User10: `/etc/sudoers.d/user9-tar` allows `sudo -u user10 /usr/bin/tar -cf /tmp/backup.tar *`. GTFOBins for tar (`--checkpoint-action=exec=/bin/bash`) yields a user10 shell. Hint: `/home/user9/user10.txt`.
- User10 → User11: `/usr/local/bin/u11-cat` (user11:user10, `4750`) exposes any file. Run it against `/home/user11/secret.txt`. Hint: `/home/user10/user11.txt`.
- User11 → User12: `sudo /usr/bin/vim /var/log/app/user12.log` is defined in `/etc/sudoers.d/user11-vim`. Escape from vim to read `/home/user12/secret.txt`. Hint: `/home/user11/user12.txt`.
- User12 → root: `nmap-5.20` is extracted from the official RPM and installed as `/usr/local/bin/nmap520` (owned `root:user12`, mode `4750`). This vintage build still supports `--interactive`; running `nmap520 --interactive` followed by `!sh` yields a root shell. Hint: `/home/user12/root.txt`.
