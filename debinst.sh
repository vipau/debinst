#!/bin/bash
## UNLICENSE file for license information

# Misc checks
_require_root() {
	if [ $(id -u) -ne 0 ]
	then
		echo "This script needs root to work." # It really does. We're installing packages.
		exit 1
	fi
}

depcheck(){
	if ! command -v "$1" >/dev/null 2>&1
	then
		echo "I require '$1' but it's not installed."
		echo "Install the '$2' package."
		exit 1
	fi
}

depcheck ar binutils
depcheck tar tar
depcheck xz xz
depcheck basename coreutils
depcheck sed sed

_list_dir="/var/debinst/lists"
if [ ! -d $_list_dir ]; then
	echo "Creating $_list_dir..."
	_require_root
	mkdir -p $_list_dir
fi

_log_dir="/var/debinst/logs"
if [ ! -d $_log_dir ]; then
	echo "Creating $_log_dir..."
	_require_root
	mkdir -p $_log_dir
fi

_usage(){
	echo 'Usage: debinst [install|remove|list] {PACKAGE.deb}'
	exit 1
}

# Install deb package
_pkg_install(){
	_package=$(basename $1)
	echo "Starting install of $_package..."
	if ! echo $_package | egrep -q "\.deb$"; then
		echo "Not a valid .deb package?"
		exit 1;
	fi
	if [ -f $_list_dir/$_package.list ]; then
		echo "Package already installed?"
		exit 1
	fi
	t=temp-$_package
	mkdir -p $t
	cp $1 $t
	cd $t
	ar x $_package
	rm $_package
	tar xf data.tar* 2>/dev/null

	list_file=$_list_dir/$_package.list
	touch $list_file
	for d in */ ; do
		find $d -mindepth 1 -type f >> $list_file
		cp -r $d / 2> /dev/null
	done
	echo "Package extracted. Now running post-install script."
	tar xf control.tar*

	log_file=$_log_dir/$_package.postinst.log
	if [ -f postinst ]
		then
		bash postinst configure > $log_file 2>&1 &&
			echo "Post-install completed succesfully." ||
			echo "Post-install script returned error. The package may or may not work. See $log_file."
	fi
	if [[ $(file $log_file) =~ "empty" ]]; then
		rm -f $log_file
	fi
	if [ ! -f postinst ]
		then
		echo "This package does not have a post-install script."
	fi
	echo "Cleaning up..."
	cd ..
	rm -rf $t
	echo "Done! A list of copied files has been created in $list_file for eventual deletion."
	exit 0
}

_pkg_remove(){
	_package=$1
	echo "Starting remove of $_package..."
	if ls $_list_dir/$1*.list 2> /dev/null > /dev/null; then
		find $_list_dir -type f -name "$1*.list" > /tmp/debinst.remove.lists
		xargs basename -a < /tmp/debinst.remove.lists | sed 's/\..*//'
		echo -n "Really remove package(s) [y/n]?: "
		read a;
		case "$a" in
			y) xargs cat < /tmp/debinst.remove.lists | sed 's/^/\//' > /tmp/debinst.remove.files
				xargs rm -f < /tmp/debinst.remove.lists
				rm /tmp/debinst.remove.lists
				xargs rm -f < /tmp/debinst.remove.files 2>/dev/null
				sed 's/\/[^/]\+$//' /tmp/debinst.remove.files | xargs rmdir -p 2>/dev/null
				rm /tmp/debinst.remove.files;;
			*) rm /tmp/debinst.remove.lists
				exit 1;;
		esac
	else
		echo "No installed .deb packages with specified name."
		exit 1
	fi
}

# Arguments check
_arg_check(){
	if [ $2 -gt $1 ]
	then
		echo "Too many arguments supplied."
		_usage
	fi
	if [ $2 -lt $1 ]
	then
		echo "Not enough arguments supplied."
		_usage
	fi
}

# All set! Start working

case "$1" in
	"install") _arg_check 2 $#; _require_root; _pkg_install $2;;
	"remove") _arg_check 2 $#; _require_root; _pkg_remove $2;;
	"list") _arg_check 1 $#
		if ls $_list_dir/*.list 2> /dev/null > /dev/null; then
			find $_list_dir -type f -printf "%f\n" | sed -n 's/^\([^.].*\)\.deb\.list$/\1/p'
		else
			echo "No installed .deb packages."
		fi;;
	"") _usage;;
	*) echo "Invalid command $1."
		_usage;;
esac
