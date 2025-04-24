```txt
 /$$   /$$ /$$$$$$$$
| $$  | $$|____ /$$/
| $$  | $$   /$$$$/
| $$  | $$  /$$__/
| $$$$$$$/ /$$$$$$$$  zsh micro plugin manager
| $$____/ |________/
| $$
| $$
 \_$
```

![GitHub file size in bytes](https://img.shields.io/github/size/KeqiZeng/uz/uz.zsh?color=green&label=uz.zsh&logo=uz.zsh%20size&style=flat-square)

[µz](https://github.com/maxrodrigo/uz) with parallel features.

## Requirements

- `zsh`
- `git`

## Usage

### Installation ###

Add the following lines to your `.zshrc` file, feel free to change the `UZ_PATH` as you like:
```zsh
export UZ_PATH=$HOME/.uz
[[ -d $UZ_PATH ]] || git clone https://github.com/KeqiZeng/uz $UZ_PATH
```

### Add Plugins

```zsh
# in .zshrc
typeset -a plugins

plugins=(
  zsh-users/zsh-completions
  esc/conda-zsh-completion
  Aloxaf/fzf-tab
  zsh-users/zsh-autosuggestions
  hlissner/zsh-autopair
  zsh-users/zsh-syntax-highlighting
)

source ${UZ_PATH}/uz.zsh
```

Then reopen the Terminal Emulator and run `zinstall`. `µz` will clone plugins from GitHub in parallel.

You don't need to do `compinit`, `µz` will do it for you. All the completion plugins will be loaded before `compinit`. The `zcompdump` file will be stored in the directory `~/.cache/zsh`.

By default `µz` will source `init.zsh` or `plugin_name.(zsh|plugin.zsh|zsh-theme|sh)` automatically, but you can also tell specify another script to the `zload` command as follows:

```zsh
zload username/repo script_name
```

### Manage Plugins

- `zclean`: removes the plugins which not in `.zshrc`.
- `zupdate`: update installed plugins in parallel.

### Installation Path

By default plugins are installed into `~/${UZ_PATH}/plugins`. This behavior can be changed re-setting `UZ_PLUGIN_PATH`.

```zsh
export UZ_PLUGIN_PATH=${UZ_PATH}/plugins # default
```

## Uninstall

To uninstall simply remove the installation directory (`$UZ_PATH`) and the modules folder (`$UZ_PLUGIN_PATH`) if applicable.
