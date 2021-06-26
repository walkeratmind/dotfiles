#!/bin/bash

# Golang install or upgrade
function getgolang() {
    sudo rm -rf /usr/local/go
    wget -q -P tmp/ https://dl.google.com/go/go"$@".linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf tmp/go"$@".linux-amd64.tar.gz
    rm -rf tmp/
    go version
}

# Rust install or upgrade
function getrust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    rustc --version
}

# Gets the download url for the latest release of a package provided via GitHub Releases
# Usage: ghrelease USER REPO [PATTERN]
ghrelease() {
    curl -s "https://api.github.com/repos/$1/$2/releases/latest" | grep -o "http.*${3}"
}

# Installs a local or remote(http/https) deb package and removes it after installation
# Example use: installdeb $(ghrelease cli cli "*linux_amd64.deb")
installdeb() {
    set -e
    loc="tmp"
    case $1 in
    http*) wget -P tmp/ $1 ;;
    *) loc="$1" ;;
    esac
    sudo dpkg -i "tmp/*.deb"
    sudo apt -f install
    sudo rm -f tmp/
}

get_all_releases() {
    # check if jq installed
    if hash jq; then
        curl "https://api.github.com/repos/aws/aws-cli/tags" | jq '.[].name'
    else
        echo "jq not installed"
    fi
}

get_latest_release() {
    # curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    # grep -Po '"tag_name": "\K.*?(?=")' |                                   # Get tag line
    # sed -E 's/.*"([^"]+)".*/\1/'                                  # Pluck JSON value

    # OR This
    curl --silent "https://github.com/$1/releases/latest" | sed 's#.*tag/\(.*\)\".*#\1#'
}

# GHCLI install or upgrade
function getghcli() {
    if hash gh; then
        echo "Already Installed"
        gh version
        echo "------------------------------------------"
        version=$(get_latest_release cli/cli)
        # echo $version
        v="${version//v/}"
        echo -n "Github's Version: "
        echo $v
        echo "------------------------------------------"
        echo -n "Reinstall or Check for Update? (Y/n): "
        read reply
        if [[ $reply == "y" || $reply == "Y" || $reply == "" ]]; then
            :
        else
            return
        fi
    fi
    curl -O -P tmp/ https://github.com/cli/cli/releases/download/"$version"/"gh_$version_linux_amd64.deb"
    # wget -q -P ~/src/ https://github.com/cli/cli/releases/tag/v"$@"/gh_"$@"_linux_amd64.deb
    sudo dpkg -i tmp/*linux_amd64.deb
    sudo apt -f install
    rm -rf tmp/
    echo "------------------------------------------"
    gh --version
}

# Hugo install or upgrade
function gethugo() {
    wget -q -P tmp/ https://github.com/gohugoio/hugo/releases/download/v"$@"/hugo_extended_"$@"_Linux-64bit.tar.gz
    tar xf tmp/hugo_extended_"$@"_Linux-64bit.tar.gz -C tmp/
    sudo mv -f tmp/hugo /usr/local/bin/
    rm -rf tmp/
    hugo version
}

# Hugo site from exampleSite in themes/
function hugotheme() {
    HUGO_THEME="$1" hugo "${@:2}" --themesDir ../.. -v
}

# Add GitLab remote to cwd git
function glab() {
    git remote set-url origin --add git@gitlab.com:rakesh niraula/"${PWD##*/}".git
    git remote -v
}
