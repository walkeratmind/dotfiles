SHELL := /bin/bash

.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install-complete: install-programs install-brew update-symlink ## Install complete packages and setup the whole system (based on personal preference. Yeah, I use brew 😃)
	install-programs
	install-brew
  # Get all upgrades
	sudo apt upgrade -y
  # See our bash changes
	source ~/.bashrc

	update-symlink
  # Fun hello
	figlet "May Linux be Merciful on You ..." | lolcat --spread 2 --animate --duration 1


install-apt-packages: ## Installs packages from scripts/aptinstall.sh
	scripts/aptinstall.sh

install-brew: ## Installs brew packages
	scripts/brewinstall.sh

install-programs: ## Run all all scripts and install programs from  /scripts/programs (excludes unused 😉)
	for f in scripts/programs/*.sh; do bash "$f" -H; done

update-symlink: ## create symbolic links for files and config
	bash scripts/symlink.sh

test:
	for d in .config/* ; do echo "$d"; done

save-dconf: ## Save dconf settings to .config/dconf/settings.dconf
	dconf dump /org/gnome/ > ~/.config/dconf/settings.dconf

save-vsce: ## Save a list of VSC extensions to .config/code/extensions.txt
	ls .vscode/extensions/ > ~/.config/code/extensions.txt

save: save-dconf save-vsce ## Update dconf and vsc extensions files

update: ## Do apt upgrade and autoremove
	sudo apt update && sudo apt upgrade -y
	sudo apt autoremove -y
