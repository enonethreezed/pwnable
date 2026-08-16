# Pwnable00

Pwnable00 is a beginner Linux privilege-escalation lab made of eleven Ubuntu virtual machines connected through a private network. Each machine has one intended path from its player account to root. Reaching root reveals the SSH credentials for the next machine.

Start the lab with:

```bash
make
```

The initial target is `user1@192.168.56.11` with password `user1`.

See `INSTALL.md` for host requirements and `CTF.md` for player rules.
