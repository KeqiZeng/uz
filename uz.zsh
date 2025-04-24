#!/usr/bin/env zsh

rm -rf /tmp/.uz_cache
unset UZ_PLUGINS
# typeset UZ_PATH=${0:A:h}
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

    local index=1
    local -aU installed_plugins to_install
    mktemp -d /tmp/.uz_cache > /dev/null
    local cache_file=$(mktemp /tmp/.uz_cache/uz_cache.XXXX)
    for plugin in ${(k)plugins[@]}; do
        echo $plugin >> $cache_file
    done

    # installed_plugins: the plugins in the UZ_PLUGIN_PATH and in the array plugins
    if [[ -d "$UZ_PLUGIN_PATH" ]]; then
        for full_path in "${UZ_PLUGIN_PATH}"/*(/N); do
            local dir_name=${full_path:t}
            installed_plugins[$index]=$(sed -n /$dir_name/p $cache_file)
            ((index++))
        done
    fi

    # echo ${installed_plugins[@]}

    index=1
    for p in ${(k)plugins[@]}; do
		(( $installed_plugins[(I)$p] )) || { to_install[$index]=$p; ((index++)) }
    done
    # echo ${to_install[@]}

    if [[ ${#to_install[@]} -eq 0 ]]; then
        echo -e "\e[1;32mAll plugins are installed.\e[0m"
	    rm -rf /tmp/.uz_cache
        return 0
    fi

    local i=1
    echo "\e[1;32mInstalling: \e[0m"
    for p in $to_install[@]; do
	    echo $p
	    file[$i]=$(mktemp /tmp/.uz_cache/uz_cache.XXXX)
	    zadd $p &> $file[$i] &
	    ((i++))
    done

    wait
    echo ""

    i=1
    for p in $to_install[@]; do
        echo -ne "\e[1;32m$p: \e[0m\n"
		command cat $file[$i]
	    ((i++))
    done
    rm -rf /tmp/.uz_cache
    echo "\ndone"
} | grep -Ev "^[\d{0,3}]$" }

zload() {
    local zmodule=${1:t} zurl=${1} zscript=${2}
    local zpath=${UZ_PLUGIN_PATH}/${zmodule}
    (( $UZ_PLUGINS[(I)$zpath] )) || UZ_PLUGINS+=("${zpath}")

    local zscripts=(${zpath}/(init.zsh|${zmodule:t}.(zsh|plugin.zsh|zsh-theme|sh))(NOL[1]))
    if [[ -f ${zpath}/${zscript} ]]; then
        source ${zpath}/${zscript}
    elif [[ -f ${zscripts} ]]; then
        source ${zscripts}
    else
        echo -e "\e[1;31mNo scripts was found for:\e[0m \e[3m${zurl}\e[0m. \e[1;32mTry to run zinstall\e[0m"
    fi
}

# Autoload
for plugin in ${(k)plugins[@]}; do
    zload $plugin
done

# compinit after plugins loaded
autoload -U compinit && compinit -d ~/.cache/zsh/zcompdump-$ZSH_VERSION

zupdate() {
{
    echo -e "\e[1;32mUpdating uz:\e[0m \e[3m${UZ_PATH}\e[0m"
    git -C ${UZ_PATH} pull

    mktemp -d /tmp/.uz_cache > /dev/null
    local -aU to_update=("${UZ_PLUGIN_PATH}"/*(N))

    local i=1
	for p in $to_update; do
		file[$i]=$(mktemp /tmp/.uz_cache/uz_cache.XXXX)
		git -C $p pull &> $file[$i] &
		((i++))
	done

    wait
    echo ""

    i=1
	for p in $to_update; do
		echo -ne "\e[1;32m${p##*/}: \e[0m\n"
		command cat $file[$i]
        echo ""
        ((i++))
    done

    rm -rf /tmp/.uz_cache
} | grep -Ev "^[\d{0,3}]$" }

zclean() {
    local -aU all_plugins=("${UZ_PLUGIN_PATH}"/*(N))
	for p in $(comm -23 <(printf '%s\n' $all_plugins | sort) <(printf '%s\n' $UZ_PLUGINS | sort)); do
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
