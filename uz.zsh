unset UZ_PLUGINS
typeset UZ_PATH=${0:A:h}
typeset UZ_PLUGIN_PATH=${UZ_PLUGIN_PATH:-${UZ_PATH}/plugins}
typeset -a UZ_PLUGINS

zinstall() {
{
  zadd() {
		local zmodule=${1:t} zurl=${1}
		local zpath=${UZ_PLUGIN_PATH}/${zmodule}
		mkdir -p ${zpath}
		git clone --recursive https://github.com/${zurl}.git ${zpath}
  }

  local index1=1
	local index2=1
  declare -a installed_plugins use_plugins to_install
  #mktemp -d /tmp/.uz_cache > /dev/null
	mkdir /tmp/.uz_cache
  local cache_file=$(mktemp /tmp/.uz_cache/uz_cache.XXXX)
  for plug in ${(k)plugins[@]}; do
		echo $plug >> $cache_file
  done

  # installed_plugins: the plugins in the UZ_PLUGIN_PATH and in the array plugins
  if [ -d "$UZ_PLUGIN_PATH" ]; then
		for dir in $(command ls -d ${UZ_PLUGIN_PATH}/* | awk -F'/' '{print $NF}'); do
			installed_plugins[$index1]=$(sed -n /$dir/p $cache_file)
			((index1++))
		done
  fi
  # echo ${installed_plugins[@]}

  for p in ${(k)plugins[@]}; do
		(( $installed_plugins[(I)$p] )) || { to_install[$index2]=$p; ((index2++)) }
  done
  # echo ${to_install[@]}

  if [[ ${#to_install[@]} -eq 0 ]]; then
		rm -rf /tmp/.uz_cache
		return 1
  fi

  local i=1
  local j=1
  echo "\e[1;32mInstalling: \e[0m"
  for p in $to_install[@]; do
		echo $p
	done
  for p in $to_install[@]; do
		file[$i]=$(mktemp /tmp/.uz_cache/uz_cache.XXXX)
		zadd $p &> $file[$i] &
		((i++))
  done
  wait
  echo ""
  for p in $to_install[@]; do
    echo -ne "\e[1;32m$p: \e[0m\n"
		command cat $file[$j]
	((j++))
  done
  rm -rf /tmp/.uz_cache
  echo "\ndone"
} | grep -Ev "^[\d{0,3}]$" }

zload() {
  local zmodule=${1:t} zurl=${1} zscript=${2}
  local zpath=${UZ_PLUGIN_PATH}/${zmodule}
  (( $UZ_PLUGINS[(I)$zpath] )) || UZ_PLUGINS+=("${zpath}")

  local zscripts=(${zpath}/(init.zsh|${zmodule:t}.(zsh|plugin.zsh|zsh-theme|sh))(NOL[1]))
  if    [[ -f ${zpath}/${zscript} ]]; then source ${zpath}/${zscript}
  elif  [[ -f ${zscripts} ]]; then source ${zscripts}
  else  echo -e "\e[1;31mNo scripts was found for:\e[0m \e[3m${zurl}\e[0m. \e[1;32mTry to run zinstall\e[0m"
  fi
}

# Autoload
# load completion plugins
for plugin in ${(k)plugins[@]}; do
  if [[ ${plugins[$plugin]} -ne 0 ]]; then
  # echo "$plugin is a completion plugin"
  zload $plugin
  fi
done

autoload -U compinit && compinit -d ~/.cache/zsh/zcompdump-$ZSH_VERSION

for plugin in ${(k)plugins[@]}; do
  if [[ ${plugins[$plugin]} -eq 0 ]]; then
  # echo "$plugin is not a completion plugin"
  zload $plugin
  fi
done


zupdate() {
{
  local i=1
  local j=1
  mktemp -d /tmp/.uz_cache > /dev/null
	for p in $(command ls -d ${UZ_PLUGIN_PATH}/*/.git); do
		file[$i]=$(mktemp /tmp/.uz_cache/uz_cache.XXXX)
		git -C ${p%/*} pull &> $file[$i] &
		((i++))
	done

  wait
  echo ""
	for p in $(command ls -d ${UZ_PLUGIN_PATH}/*/.git); do
		echo -ne "\e[1;32m${${p%/*}:t}: \e[0m\n"
		command cat $file[$j]
	echo ""
	((j++))
done
  rm -rf /tmp/.uz_cache
} | grep -Ev "^[\d{0,3}]$" }

zclean() {
	for p in $(comm -23 <(command ls -1d ${UZ_PLUGIN_PATH}/* | sort) <(printf '%s\n' $UZ_PLUGINS | sort)); do
		while read "?Are you sure to clean $(echo "$p" | awk -F'/' '{print $NF}')? [y/n] " input; do
			if [[ $input = "y" || $input = "Y" ]]; then
				echo -e "\e[1;33mCleaning:\e[0m \e[3m${p}\e[0m"
				rm -rf $p
				break
			elif [[ $input = "n" || $input = "N" ]]; then
				break
			else
				echo -e "\e[1;31mInvalid input\e[0m, please input \e[1;32my/Y or n/N\e[0m."
			fi
		done
	done
}
