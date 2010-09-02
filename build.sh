#!/bin/bash

xfcedir=$HOME/pkgs/xfce-git

_date=$(date +%Y%m%d)
_rdate=$(date +%H%m)

pkg_dir=$HOME/pkgs/XFCE_$_date-$_rdate

_ppath="
xfce4-dev-tools-git
gtk-xfce-engine-git
xfce4-icon-theme-git
libxfce4util-git
garcon-git
exo-git
xfconf-git
libxfce4ui-git
xfwm4-git
xfce4-appfinder-git
libxfce4menu-git
xfce4-panel-git
xfdesktop-git
terminal-git
thunar-git
xfce4-session-git
xfce4-settings-git
xfce4-appfinder-git
"

print_ok(){
echo -e "\e[1;32m \t\t $1 \e[1;0m"
}
print_warn(){
echo -e "\e[1;31m \t $1 \e[1;0m"
}


_pkgmk(){
	sed -i "s/version=.*/version="${_date}"/" Pkgfile || exit 1
	sed -i "s/release=.*/release="${_rdate}"/" Pkgfile || exit 1

	fakeroot pkgmk -if -ns -f > "${pkg_dir}/${_path}_build_log" 2>&1 || exit 1

	if grep -q "${_path}" /var/lib/pkg/db ; then
		sudo pkgrm "${_path}"
		sudo pkgadd "${_path}#${_date}-${_rdate}.pkg.tar.xz" || exit 1
		print_ok "${_path} updated "
	else
		sudo pkgadd "${_path}#${_date}-${_rdate}.pkg.tar.xz" || exit 1
		echo -e "${_path} installed "
	fi
	mv "${_path}#${_date}-${_rdate}.pkg.tar.xz" "${pkg_dir}"
}


mkdir -p $pkg_dir
echo "$_ppath" | while _path=`line`
do
	if [ "$_path" != "" ]; then
		echo "------------------------------------------------------------------"
		if echo "${_path}" | grep -q "\#" ; then
			print_warn " skip ${_path} "
		else
			if cd "${xfcedir}/${_path}" ; then
				print_ok "building ${_path} "
				_pkgmk || exit 1
			else
				print_warn "ERROR:  No such directory  ${xfcedir}/${_path} "
				exit
			fi
	fi
fi
done
