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

## Installation

Just clone from GitHub

```sh
git clone https://github.com/KeqiZeng/uz.git ~/.uz
```

## Usage

### Add Plugins

```zsh
# in .zshrc
declare -A plugins

plugins=(
  ['zsh-users/zsh-completions']="( [completion]=0 [frozen]=1 )" # 0: true 1: false
  ['esc/conda-zsh-completion']="( [completion]=0 [frozen]=1 )"
  ['Aloxaf/fzf-tab']="( [completion]=1 [frozen]=1 )"
  ['zsh-users/zsh-autosuggestions']="( [completion]=1 [frozen]=1 )"
  ['hlissner/zsh-autopair']="( [completion]=1 [frozen]=0 )"
  ['zdharma-continuum/fast-syntax-highlighting']="( [completion]=1 [frozen]=1 )"
)

source ~/.dotfiles/zsh/uz/uz.zsh
```
**Note:** If a plugin is a completion plugin, please set `completion` to `0`. If you don't want `µz` to update a plugin, set `frozen` to `0`.
Then `source ~/.zshrc` or reopen the Terminal Emulator and run `zinstall`. `µz` will clone plugins in parallel.

You don't need to do `compinit`, `µz` will do it for you. All the completion plugins will be loaded before `compinit`, others will be loaded after. The `zcompdump` file will be stored in the directory `~/.cache/zsh`.

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

~~`μz` only creates folders for the cloned modules and, by default, are self contained into the installation directory.~~

For pretty output, `μz` will create `.uz_cache` folder in `/tmp` directory, when run `zinstall` and `zupdate`. But don't worry about it, once the commands are over, `.uz_cache` will be removed.

To uninstall remove the installation directory (`$UZ_PATH`) and the modules folder (`$UZ_PLUGIN_PATH`) if applicable.
