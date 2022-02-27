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

[µz](https://github.com/maxrodrigo/uz) with parallel install and update.

## Requirements

- `zsh`
- `git`

### Options

- [`exa`](https://github.com/ogham/exa)
- [`bat`](https://github.com/sharkdp/bat)

## Installation

Just clone from GitHub

```sh
git clone https://github.com/KeqiZeng/uz.git ~/.uz
```

## Usage

### Add Plugins

Add plugins' Github repo to the array `plugins` in `.zshrc` and source `uz.zsh`

An example:

```zsh
# in .zshrc
plugins=(
	'zsh-users/zsh-completions'
	'Aloxaf/fzf-tab'
	'zsh-users/zsh-autosuggestions'
	'hlissner/zsh-autopair'
	'zdharma-continuum/fast-syntax-highlighting'
	'jeffreytse/zsh-vi-mode'
	# ...
	)

source ~/.uz/uz.zsh
```

Then `source ~/.zshrc` or reopen the Terminal Emulator and run `zinstall`. `µz` will clone plugins in parallel.

By default `µz` will source `init.zsh` or `plugin_name.(zsh|plugin.zsh|zsh-theme|sh)` automatically, but you can also tell it don't do that for you (for example you use [`zsh-vi-mode`](https://github.com/jeffreytse/zsh-vi-mode), and let it source some special plugins for you after `zsh-vi-mode` has been loaded, to avoid `zvm` overwritting the previous key bindings. In this special case, maybe you don't want `µz` to load these plugins again).

An example:

```zsh
# don't autoload the plugins in the array dis_autoloads
# add this before source uz.zsh
dis_autoloads=(
	      'hlissner/zsh-autopair'
	      'zdharma-continuum/fast-syntax-highlighting'
		# ...
	)

```

```zsh
# manually load
# after source uz.zsh
zload username/repo
```

Besides, you can also tell specify another script to the `zload` command as follows:

```zsh
zload username/repo script_name
```

### Manage Plugins

- `zclean`: removes plugins no longer in the array `plugins`.
- `zupdate`: update installed plugins in parallel.

### Installation Path

By default plugins are installed into `~/${UZ_PATH}/plugins`. This behavior can be changed re-setting `UZ_PLUGIN_PATH`.

```zsh
export UZ_PLUGIN_PATH=${UZ_PATH}/plugins # default
```

### Options

If you use `exa` to replace `ls`, you can tell `µz` to use `exa` instead of `ls`.
For `bat` to replace `cat`, it's same.

```zsh
# in .zshrc
export UZ_USE_EXA=true
export UZ_USE_BAT=true
```

## Uninstall

~~`μz` only creates folders for the cloned modules and, by default, are self contained into the installation directory.~~

For pretty output, `μz` will create `.uz_cache` folder in current directory, when run `zinstall` adn `zupdate`. But don't worry about it, once the commands are over, `.uz_cache` will be removed.

To uninstall remove the installation directory (`$UZ_PATH`) and the modules folder (`$UZ_PLUGIN_PATH`) if applicable.
