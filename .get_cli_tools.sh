#!/bin/bash

# Golang install or upgrade
function getgolang () {
    sudo rm -rf /usr/local/go
    wget -q -P tmp/ https://dl.google.com/go/go"$@".linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf tmp/go"$@".linux-amd64.tar.gz
    rm -rf tmp/
    echo go --version
}

# Rust install or upgrade
function getrust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    echo rustc --version
}

# Gets the download url for the latest release of a package provided via GitHub Releases
# Usage: ghrelease USER REPO [PATTERN]
ghrelease() {
	curl -s "https://api.github.com/repos/$1/$2/releases/latest" | grep -o "http.*${3}"
}

# Installs a local or remote(http/https) deb package and removes it after installation
# Example use: installdeb $(ghrelease cli cli "gh_*_linux_amd64.deb")
installdeb() {
	set -e
	loc="/tmp/install.deb"
	case $1 in 
	http*) sudo wget -O "$loc" $1;;
	*) loc="$1"
	esac
	sudo dpkg -i "$loc"
	sudo apt -f install
	sudo rm -f "$loc"
}

get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep -Po '"tag_name": "\K.*?(?=")'                                         # Get tag line
    # sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

# GHCLI install or upgrade
function getghcli () {
    # installdeb $(ghrelease cli cli "gh_*_linux_amd64.*deb")
    version="${get_latest_release cli/cli}"
    echo $version
    $v="${version//v}"
    echo $v
    wget -q -P ~/src/ https://github.com/cli/cli/releases/tag/"$version"
    # wget -q -P ~/src/ https://github.com/cli/cli/releases/tag/v"$@"/gh_"$@"_linux_amd64.deb
    cd ~/src/ && sudo dpkg -i gh_"$@"_linux_amd64.deb
    cd .. && rm src/gh_"$@"_linux_amd64.deb
    echo "------------------"
    gh --version
}

# Hugo install or upgrade
function gethugo () {
    wget -q -P tmp/ https://github.com/gohugoio/hugo/releases/download/v"$@"/hugo_extended_"$@"_Linux-64bit.tar.gz
    tar xf tmp/hugo_extended_"$@"_Linux-64bit.tar.gz -C tmp/
    sudo mv -f tmp/hugo /usr/local/bin/
    rm -rf tmp/
    hugo version
}

# Hugo site from exampleSite in themes/
function hugotheme () {
    HUGO_THEME="$1" hugo "${@:2}" --themesDir ../.. -v
}

# Add GitLab remote to cwd git
function glab () {
    git remote set-url origin --add git@gitlab.com:rakesh niraula/"${PWD##*/}".git
    git remote -v
}
