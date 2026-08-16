.DEFAULT_GOAL := up

.PHONY: help up provision halt reload destroy ssh status rebuild clean

VM ?=

help:
	@echo "Targets:"
	@echo "  up         Create and provision all 11 lab nodes"
	@echo "  provision  Re-run provisioners (set VM=nodeN for one node)"
	@echo "  halt       Stop all nodes (set VM=nodeN for one node)"
	@echo "  reload     Restart all nodes (set VM=nodeN for one node)"
	@echo "  destroy    Destroy all nodes (set VM=nodeN for one node)"
	@echo "  ssh        Connect with Vagrant (requires VM=nodeN)"
	@echo "  status     Show node status"
	@echo "  rebuild    Destroy and recreate all nodes"
	@echo "  clean      Remove local Vagrant artifacts (.vagrant)"

up:
	vagrant up --provision

provision:
	vagrant provision $(VM)

halt:
	vagrant halt $(VM)

reload:
	vagrant reload $(VM)

destroy:
	vagrant destroy -f $(VM)

ssh:
	@test -n "$(VM)" || (echo "Set VM=nodeN" >&2; exit 1)
	vagrant ssh $(VM)

status:
	vagrant status

rebuild:
	vagrant destroy -f
	vagrant up --provision

clean:
	rm -rf .vagrant
