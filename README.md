# dotfiles 🏗️ for Linux 💻️

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Pop! OS](https://img.shields.io/badge/Pop!_OS-48B9C7?style=for-the-badge&logo=Pop!_OS&logoColor=white)
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

To be honest, I haven't written all these scripts and configs. I copied most of the parts from others whose link you can find in [references](#references-%EF%B8%8F) ⬇️.

As we all know, every person have his/her own needs so, ➡️ evey person needs his/her own dotfiles (I suppose 😎️😎️😎️).

>NOte: This is current version of configuration which is running now.

> Current OS: 🎡️ Elementary OS

## File Strucutre 📑️

```bash
.
├── .bashrc.d
│   └── .git-completion.bash
├── .config
│   ├── alacritty.yml
│   ├── init.vim
│   └── starship.toml
├── .doom.d
│   └── config.el
├── scripts
│   ├── programs
│   │   ├── docker.sh
│   │   ├── nvm.sh
│   │   ├── python.sh
│   │   ├── typora.sh
│   │   ├── vsc.sh
│   │   ├── vundle.sh
│   │   └── zsh.sh
│   ├── aptinstall.sh
│   ├── setup.sh
│   └── symlink.sh
├── .shellrc.d
│   ├── adb_tricks.sh
│   ├── api.sh
│   ├── extract.sh
│   ├── get_cli_tools.sh
│   ├── py_tricks.sh
│   ├── tricks.sh
│   ├── utils.sh
│   └── ydl.sh
├── .aliases
├── .bash_profile
├── .bashrc
├── .curlrc
├── .env.sh
├── .gitconfig
├── .tmux.conf
├── .vimrc
└── .zshrc

```

------

## Setup

>Goto `scripts` directory and Run the below command for full installation:

`$ sudo bash setup.sh`

### Partial Setup

>To setup only the bash or other configurations only, run `symlink.sh` file in your terminal.

`$ sudo bash symlink.sh`

>You can run any bash file you want

`$ sudo bash <filename.sh>`

------

## References 👇️

> More Than References, kind of like mixture of all these,

> Yeah, you can call me cheater

> 😋️😋️😋️

> 😎️😎️😎️

[victoriadrake](https://github.com/victoriadrake/dotfiles)

[tomnomnom](https://github.com/tomnomnom/dotfiles)

[👨‍🏫️ rhoit](https://github.com/rhoit/my-config)
