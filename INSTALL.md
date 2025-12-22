# Installation Guide

These steps target Ubuntu 24.04 (Noble) using only packages from the official distribution so updates arrive via the regular `apt` flow.

## 1. Install VirtualBox
```bash
sudo apt update
sudo apt install --yes virtualbox virtualbox-dkms virtualbox-ext-pack
```
The Ubuntu packages track Oracle’s releases while staying integrated with the kernel shipped by the distribution.

## 2. Install Vagrant
```bash
sudo apt install --yes vagrant
```
No extra plugins are needed to drive VirtualBox; the packaged Vagrant binary already includes that provider.

## 3. Clone This Repository
```bash
git clone https://github.com/enonethreezed/pwnable
cd pwnable
```
Replace the URL if you use a fork or a private mirror.

## 4. Create and Provision the VM
```bash
vagrant up --provision
```
This downloads the `bento/ubuntu-22.04` base box, boots VirtualBox with 2 GB RAM / 128 MB VRAM, and executes every provisioning script under `scripts/`.

To enter the VM afterward:
```bash
vagrant ssh
```
From there you can `su - user1` or any other user as needed.

## 5. Re-run Provisioners
When you change the Vagrantfile or any script:
```bash
vagrant provision
```
If you only need a specific script, run it directly inside the guest:
```bash
vagrant ssh -c 'sudo bash /vagrant/scripts/provision_users.sh'
vagrant ssh -c 'sudo bash /vagrant/scripts/setup_challenge.sh'
```

## 6. Rebuild from Scratch
To reset everything:
```bash
vagrant destroy -f
vagrant up --provision
```
Destroying wipes disks and snapshots; only run it when you want a fresh lab.

## 7. Helpful Flags & Checks
- Set `CTFADMIN=false vagrant up` to trigger the logic in the Vagrantfile that randomizes the `vagrant` user password and removes its sudo drop-in.
- Use `vagrant status` to verify whether the VM is running, powered off, or absent.
- Keep VirtualBox patched by running `sudo apt full-upgrade` on the host; the hypervisor packages will upgrade alongside the kernel.

With VirtualBox and Vagrant installed from Ubuntu’s repositories, the full lab can always be recreated with `vagrant destroy -f && vagrant up --provision`. Consult `README.md`, `STATE_OF_THE_ART.md`, `CTF.md`, and `SOLUTIONS.md` for deeper context once the VM is running.

## Troubleshooting
- **Provisioning fails mid-way:** rerun `vagrant provision` or execute `sudo bash /vagrant/scripts/setup_challenge.sh`.
- **Cron/sudo steps fail:** check that `/etc/cron.d/*` and `/etc/sudoers.d/*` keep `0640`/`0440` permissions, then reprovision.
- **SSH port already in use:** export a different `PLAYER_SSH_PORT` and run `vagrant up` again.
