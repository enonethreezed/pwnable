# Pwnable00 Beginner CTF

Welcome to a hands-on capture-the-flag for people taking their first steps into Linux privilege escalation. The virtual machine contains a long chain of users, and every jump relies on nothing but misconfigured permissions: writable cron jobs, risky SUID binaries, sloppy sudo rules, and files with the wrong ownership. No kernel exploits, no fuzzing—just careful enumeration and abuse of everyday mistakes.

Because the challenges mirror real-world paths, [GTFOBins](https://gtfobins.github.io/) is your best friend. If a binary shows up with SUID or sudo, look it up there and replicate the documented technique inside this lab.

Need the full background on how the VM is provisioned, the escalation storyline, or exact solutions? Check `STATE_OF_THE_ART.md`, `CTF.md`, and `SOLUTIONS.md`.

## Network Isolation
`scripts/setup_challenge.sh` enables `ufw` inside each VM with a default deny (incoming/outgoing) policy. Only loopback traffic and inbound SSH (TCP/22) stay open, preventing contestants from pivoting to the wider network while still allowing SSH access through the forwarded port.
