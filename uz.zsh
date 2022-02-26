unset UZ_PLUGINS
typeset UZ_PATH=${0:A:h}
typeset UZ_PLUGIN_PATH=${UZ_PLUGIN_PATH:-${UZ_PATH}/plugins}
typeset -a UZ_PLUGINS

zadd() {
  local zmodule=${1:t} zurl=${1}
  local zpath=${UZ_PLUGIN_PATH}/${zmodule}
  mkdir -p ${zpath}
  git clone --recursive https://github.com/${zurl}.git ${zpath}
}

zinstall() {
  local index1=1 index2=1 index3=1 exist=0
  declare -a installed_plugins use_plugins to_install
  mktemp -d .uz_cache > /dev/null
  local cache_file=$(mktemp .uz_cache/uz_cache.XXXX)
  for plug in $plugins[@]; do
	echo $plug >> $cache_file
  done

  if [ -d "$UZ_PLUGIN_PATH" ]; then
	if [ "${UZ_USE_EXA}" = true ]; then
	  for dir in $(exa -d --no-icons ${UZ_PLUGIN_PATH}/* | awk -F'/' '{print $NF}'); do
		installed_plugins[$index1]=$(sed -n /$dir/p $cache_file)
		((index1++))
	  done
	else
      for dir in $(ls -d ${UZ_PLUGIN_PATH}/* | awk -F'/' '{print $NF}'); do
        installed_plugins[$index1]=$(sed -n /$dir/p $cache_file)
        ((index1++))
      done
	fi
  fi


  while [[ $index2 -le ${#plugins[@]} ]]; do
    use_plugins[$index2]=$(sed -n ${index2}p $cache_file)
	((index2++))
  done

  for up in $use_plugins[@]; do
	for ip in $installed_plugins[@]; do
	  if [ "$up" = "$ip" ]; then
		exist=1
		break
	  else
	  	exist=0
	  fi
	done
	if [[ $exist -eq 0 ]]; then
	  to_install[$index3]=$up
	  ((index3++))
	fi
  done

  if [ ${#to_install[@]} -eq 0 ]; then
	rm -rf .uz_cache
	return 1
  fi

  local i=1
  local j=1
  echo "\e[1;32mInstalling: \e[0m"
  for p in $to_install[@]; do
	echo $p
  done
  echo ""
  for p in $to_install[@]; do
	file[$i]=$(mktemp .uz_cache/uz_cache.XXXX)
	zadd $p &> $file[$i] &
	((i++))
  done
  wait
  echo ""
  for p in $to_install[@]; do
    echo -ne "\e[1;32m$p: \e[0m\n"
	if [ "${UZ_USE_BAT}" = true ]; then
	  bat -p $file[$j]
	else
	  cat $file[$j]
	fi
	((j++))
  done
  rm -rf .uz_cache
  echo "\ndone"
}

zload() {
  local zmodule=${1:t} zurl=${1} zscript=${2}
  local zpath=${UZ_PLUGIN_PATH}/${zmodule}
  UZ_PLUGINS+=("${zpath}")

  local zscripts=(${zpath}/(init.zsh|${zmodule:t}.(zsh|plugin.zsh|zsh-theme|sh))(NOL[1]))
  if    [[ -f ${zpath}/${zscript} ]]; then source ${zpath}/${zscript}
  elif  [[ -f ${zscripts} ]]; then source ${zscripts}
  else  echo -e "\e[1;31mNo scripts was found for:\e[0m \e[3m${zurl}\e[0m. \e[1;32mTry to run zinstall\e[0m"
  fi
}

for plugin in ${plugins[@]}; do
	zload $plugin
done

zupdate() {
  local i=1
  local j=1
  mktemp -d .uz_cache > /dev/null
  if [ "${UZ_USE_EXA}" = true ]; then
    for p in $(exa -d --no-icons ${UZ_PLUGIN_PATH}/*/.git); do
	  file[$i]=$(mktemp .uz_cache/uz_cache.XXXX)
	  git -C ${p%/*} pull > $file[$i] &
	  ((i++))
    done
  else
    for p in $(ls -d ${UZ_PLUGIN_PATH}/*/.git); do
	  file[$i]=$(mktemp .uz_cache/uz_cache.XXXX)
	  git -C ${p%/*} pull > $file[$i] &
	  ((i++))
    done
  fi

  wait
  echo ""
  if [ "${UZ_USE_EXA}" = true ]; then
    for p in $(exa -d --no-icons ${UZ_PLUGIN_PATH}/*/.git); do
      echo -ne "\e[1;32m${${p%/*}:t}: \e[0m\n"
	  if [ "${UZ_USE_BAT}" = true ]; then
	    bat -p $file[$j]
	  else
	  	cat $file[$j]
	  fi
	  echo ""
	  ((j++))
    done
  else
    for p in $(ls -d ${UZ_PLUGIN_PATH}/*/.git); do
      echo -ne "\e[1;32m${${p%/*}:t}: \e[0m\n"
	  if [ "${UZ_USE_BAT}" = true ]; then
	    bat -p $file[$j]
	  else
	  	cat $file[$j]
	  fi
	  echo ""
	  ((j++))
	done
  fi
  rm -rf .uz_cache
}

zclean() {
  if [ "${UZ_USE_EXA}" = true ]; then
    for p in $(comm -23 <(exa -1d --no-icons ${UZ_PLUGIN_PATH}/* | sort) <(printf '%s\n' $UZ_PLUGINS | sort)); do
      echo -e "\e[1;33mCleaning:\e[0m \e[3m${p}\e[0m"
      rm -rf $p
    done
  else
    for p in $(comm -23 <(ls -1d ${UZ_PLUGIN_PATH}/* | sort) <(printf '%s\n' $UZ_PLUGINS | sort)); do
      echo -e "\e[1;33mCleaning:\e[0m \e[3m${p}\e[0m"
      rm -rf $p
    done
  fi
}
