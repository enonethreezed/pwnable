.PHONY: help install up provision halt reload destroy ssh status rebuild clean ctf

help:
	@echo "Targets:"
	@echo "  install    Install host dependencies (VirtualBox + Vagrant on Ubuntu)"
	@echo "  up         Create and provision the VM"
	@echo "  ctf        Create/provision with CTFADMIN=false (lock vagrant password)"
	@echo "  provision  Re-run provisioners"
	@echo "  halt       Stop the VM"
	@echo "  reload     Restart the VM"
	@echo "  destroy    Destroy the VM"
	@echo "  ssh        SSH into the VM"
	@echo "  status     Show VM status"
	@echo "  rebuild    Destroy and rebuild the VM"
	@echo "  clean      Remove local Vagrant artifacts (.vagrant)"
	@echo ""
	@echo "Environment:"
	@echo "  CTFADMIN=false  Randomize vagrant password and remove its sudo drop-in"

install:
	sudo apt update
	sudo apt install --yes virtualbox virtualbox-dkms virtualbox-ext-pack vagrant

up:
	vagrant up --provision

ctf:
	CTFADMIN=false vagrant up --provision
	CTFADMIN=false vagrant provision

provision:
	vagrant provision

halt:
	vagrant halt

reload:
	vagrant reload

destroy:
	vagrant destroy -f

ssh:
	vagrant ssh

status:
	vagrant status

rebuild:
	vagrant destroy -f
	vagrant up --provision

clean:
	rm -rf .vagrant
