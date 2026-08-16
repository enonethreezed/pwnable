# Lab Handoff

## Current Architecture

- The lab is an 11-node Vagrant environment, not the former single-VM user chain.
- Nodes are named `node1` through `node11` and use `192.168.56.11` through `192.168.56.21` on Vagrant's private network.
- Each VirtualBox guest is configured with 512 MB RAM and no GUI.
- Plain `make` runs `vagrant up --provision` for the complete lab.
- Each guest has one player account, named `user1` through `user11`. The initial access is `user1` / `user1` on `192.168.56.11`.

## Challenge Rules

- Every node has one path from its player account to root.
- Use standard system binaries and deliberately weak standard configuration only. Do not introduce custom vulnerable binaries or wrappers.
- GTFOBins is the reference for binary-based paths.
- Each player home contains `README.txt` with only the relevant GTFOBins URL.
- `/root/user.txt` reveals the next node's IP address, account, and password after root is obtained. Node 11 contains the completion message.
- The legacy Nmap 5.20 path and all former custom helper binaries are retired.

## Implemented Matrix

1. `sudo find`
2. `sudo tar`
3. `sudo vim`
4. `sudo less`
5. `sudo awk`
6. `sudo python3`
7. Python with `cap_setuid`
8. SUID `bash`
9. Root cron job running a player-writable shell script
10. Root systemd timer running a player-writable shell script
11. `sudo rsync`

## Provisioning

- `Vagrantfile` defines the topology and calls `scripts/provision_node.sh` once per node.
- The provisioner updates the guest, removes SUID from `pkexec`, enables password SSH, and revokes Vagrant's bootstrap sudo access after provisioning.
- Passwords are sourced from `PASSWORDS.md`; only `user1` through `user11` are used by the new lab.

## Validation Status

- `scripts/provision_node.sh` passes `bash -n` and repository whitespace checks.
- Runtime validation has not been performed: the development VM lacks `make`, `vagrant`, and sufficient memory to boot all 11 guests.
- Validate every escalation and next-hop SSH connection on a host with VirtualBox and Vagrant before finalizing player-facing documentation.

## Documentation Status

- `README.md`, `INSTALL.md`, `CTF.md`, `SOLUTIONS.md`, and `PASSWORDS.md` still contain material from the retired single-VM lab.
- Do not treat those files as current player documentation.
- After end-to-end validation, replace player-facing documentation with the minimal deployment instruction and move solution material outside the player-facing repository or ignore it as appropriate.
