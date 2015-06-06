# linux-stuff
Scripts and aliases to make the life of a linux user (ubuntu/mint) a bit easier.

# Installation
`git clone git@github.com:rhpaiva/linux-stuff.git`

- For ubuntu users, copy `aliases/.bash_aliases` to your home folder.
- For mint, copy the same file with the name `.bashrc` to your home folder.

# Running scripts/setup-new-machine.sh
- `bash scripts/setup-new-machine.sh` or 
- `chmod u+x scripts/setup-new-machine.sh` and then `./scripts/setup-new-machine.sh`

Usage: 
`setup-new-machine.sh <installation-name>`, where `<installation-name>` 
comes from the name of the function you want to execute. Example:

`setup-new-machine initial` will execute the installation of initial packages defined in `function install_initial()`.
