# Installation Guide

## Requirements

- VirtualBox
- Vagrant with the VirtualBox provider
- At least 8 GB RAM available to the host: the lab runs eleven guests with 512 MB each, plus VirtualBox and host overhead.

On Ubuntu hosts, install the required packages with:

```bash
sudo apt update
sudo apt install --yes virtualbox virtualbox-dkms virtualbox-ext-pack vagrant
```

## Deploy

```bash
git clone https://github.com/enonethreezed/pwnable
cd pwnable
make
```

`make` creates and provisions `node1` through `node11`. The nodes use the private network `192.168.56.0/24`, from `192.168.56.11` through `192.168.56.21`.

## Start Playing

```bash
ssh user1@192.168.56.11
```

Use password `user1`. Each account home contains a `README.txt` with a reference URL. After obtaining root, read `/root/user.txt` for the next connection.

## Management

```bash
make status
make ssh VM=node1
make halt
make reload
make destroy
make rebuild
```

`make rebuild` destroys and recreates the full lab. Use it to obtain a clean lab state.
