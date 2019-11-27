#!/usr/bin/env bash

set -e
set -u


function is_darwin() {
	if [ "$(uname)" == "Darwin" ]; then
		return 0
	else
		return 1
	fi
}


function get_col() {

	## Package names are printed in the third column only in darwin(osx)
	## https://github.com/atom/apm/blob/master/src/stars.coffee#L80
	if is_darwin; then
		echo 3
	else
		echo 2
	fi
}


function get_installed_packages() {
	apm list -i -b | sed -e 's/@.\+$//g' | sed -e '/^\s*$/d' | sort
}


function get_starred_packages() {
	apm starred --color false | sed -e '1d' | head -n -3 | awk -v col=$(get_col) '{ print $col }' | sed -e '/^\s*$/d' | sort
}


function print_package_names() {
	for p in "$@"
	do
		echo "  $p"
	done
	echo
}


function install() {

	## packages starred but not installed
	target_packages=( $(join -v 1 <(get_starred_packages) <(get_installed_packages)) )

	if [ ${#target_packages[@]} -eq 0 ]; then
		echo "Nothing to install."
	else
		echo "Packages to be installed (${#target_packages[@]}):"
		print_package_names "${target_packages[@]}"
		apm install "${target_packages[@]}"
	fi
}


function uninstall() {

	## packages installed but not starred
	target_packages=( $(join -v 2 <(get_starred_packages) <(get_installed_packages)) )

	if [ ${#target_packages[@]} -eq 0 ]; then
		echo "Nothing to uninstall."
	else
		echo "Packages to be uninstalled (${#target_packages[@]}):"
		print_package_names "${target_packages[@]}"
		apm uninstall "${target_packages[@]}"
	fi
}


function star() {

	## packages installed but not starred
	target_packages=( $(join -v 2 <(get_starred_packages) <(get_installed_packages)) )

	if [ ${#target_packages[@]} -eq 0 ]; then
		echo "Nothing to star."
	else
		echo "Packages to be starred (${#target_packages[@]}):"
		print_package_names "${target_packages[@]}"
		apm star "${target_packages[@]}"
	fi
}


function unstar() {

	## packages starred but not installed
	target_packages=( $(join -v 1 <(get_starred_packages) <(get_installed_packages)) )

	if [ ${#target_packages[@]} -eq 0 ]; then
		echo "Nothing to unstar."
	else
		echo "Packages to be unstarred (${#target_packages[@]}):"
		print_package_names "${target_packages[@]}"
		apm unstar "${target_packages[@]}"
	fi
}


function pull() {

	starred_packages=$(get_starred_packages)
	installed_packages=$(get_installed_packages)

	## packages starred but not installed
	target_install=( $(join -v 1 <(echo "$starred_packages") <(echo "$installed_packages")) )

	## packages not starred but installed
	target_uninstall=( $(join -v 2 <(echo "$starred_packages") <(echo "$installed_packages")) )

	if [ ${#target_install[@]} -eq 0 ]; then
		if [ ${#target_uninstall[@]} -eq 0 ]; then
			echo "Already up-to-date."
		else
			echo "Packages to be uninstalled (${#target_uninstall[@]}):"
			print_package_names "${target_uninstall[@]}"
		fi
	else
		echo "Packages to be installed (${#target_install[@]}):"
		print_package_names "${target_install[@]}"

		if [ ${#target_uninstall[@]} -gt 0 ]; then
			echo "Packages to be uninstalled (${#target_uninstall[@]}):"
			print_package_names "${target_uninstall[@]}"
		fi
	fi

	if [ ${#target_install[@]} -gt 0 ]; then
		apm install "${target_install[@]}"
	fi

	if [ ${#target_uninstall[@]} -gt 0 ]; then
		apm uninstall "${target_uninstall[@]}"
	fi
}


function push() {

	starred_packages=$(get_starred_packages)
	installed_packages=$(get_installed_packages)

	## packages installed but not starred
	target_star=( $(join -v 2 <(echo "$starred_packages") <(echo "$installed_packages")) )

	## packages not installed but starred
	target_unstar=( $(join -v 1 <(echo "$starred_packages") <(echo "$installed_packages")) )

	if [ ${#target_star[@]} -eq 0 ]; then
		if [ ${#target_unstar[@]} -eq 0 ]; then
			echo "Already up-to-date."
		else
			echo "Packages to be unstarred (${#target_unstar[@]}):"
			print_package_names "${target_unstar[@]}"
		fi
	else
		echo "Packages to be starred (${#target_star[@]}):"
		print_package_names "${target_star[@]}"

		if [ ${#target_unstar[@]} -gt 0 ]; then
			echo "Packages to be unstarred (${#target_unstar[@]}):"
			print_package_names "${target_unstar[@]}"
		fi
	fi

	if [ ${#target_star[@]} -gt 0 ]; then
		apm star "${target_star[@]}"
	fi

	if [ ${#target_unstar[@]} -gt 0 ]; then
		apm unstar "${target_unstar[@]}"
	fi
}


function status() {

	starred_packages=$(get_starred_packages)
	installed_packages=$(get_installed_packages)

	synced=( $(join <(echo "$starred_packages") <(echo "$installed_packages")) )
	only_starred=( $(join -v 1 <(echo "$starred_packages") <(echo "$installed_packages")) )
	only_installed=( $(join -v 2 <(echo "$starred_packages") <(echo "$installed_packages")) )

	echo "Starred and installed (${#synced[@]}):"
	print_package_names "${synced[@]}"

	echo "Starred but not installed (${#only_starred[@]}):"
	print_package_names "${only_starred[@]}"

	echo "Installed but not starred (${#only_installed[@]}):"
	print_package_names "${only_installed[@]}"
}


function usage() {
	cat <<EOF
Usage: $(basename "$0") <command>

Commands:
	install
	uninstall
	star
	unstar
	pull
	push
	status
	usage
	help
EOF
}


function error() {
	usage 1>&2
}


if [ $# -gt 1 ]; then
	error
	exit 1
fi

if [ $# -eq 0 ]; then
	status
	exit 0
fi

case "$1" in
	"install")   install ;;
	"uninstall") uninstall ;;
	"star")      star ;;
	"unstar")    unstar ;;
	"pull")      pull ;;
	"push")      push ;;
	"status")    status ;;
	"usage")     usage ;;
	"help")      usage ;;
	*)
		error
		exit 1
		;;
esac
