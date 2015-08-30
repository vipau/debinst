#!/usr/bin/bash

# See UNLICENSE file for license information

# Misc checks
if ! test $(whoami) = "root"
then
	echo "This script needs root to work." # It really does. We're installing packages.
	exit 1
fi

depcheck () {
		if ! command -v "$1" >/dev/null 2>&1
		then
			echo "I require \`"$1"\` but it's not installed."
			echo "Install the \`"${@: -1}"\` package."
			# ${@: -1} is bashism for "last argument passed"
			# This is done instead of $2 to avoid writing "depcheck tar tar"
		        # I suck at being evil, I know.	
exit 1 
fi
}

depcheck bash
depcheck ar binutils
depcheck tar
depcheck basename coreutils

n=$(basename $1)

# Arguments check
if [ $# -eq 0 ]
	then
		echo "No arguments supplied."
		echo "Usage: ./debinst package.deb"
		exit 1
	elif [ $# -ne 1 ]
	then
		echo "Too many arguments supplied"
		echo "Usage: ./debinst package.deb"
		exit 1
	# I may change this =~ to a `grep -Eq` for older bash and plain sh users in the future
	# First check .deb extension, then file magic
	elif [[ ! $1 =~ \.deb$ ]] || ! [[ $(file -b $1) =~ Debian* ]] 
	then
		echo "The specified file does not look like a valid .deb archive"
		exit 1
fi

# All set! Start working

t=temp-$n
echo "$t $n"
mkdir -p $t
cp $1 $t
cd $t
ar x $n
rm $n

if [ -f data.tar.gz ]
	then
        tar xzf data.tar.gz 2>/dev/null
fi
if [ -f data.tar.xz ]
	then
	tar xJf data.tar.xz 2>/dev/null
fi

touch $n.list
for d in */ ; do
	find $d -mindepth 2 >> ../$n.list
	cp -rT $d / 2> /dev/null
	cp -R $d / 2> /dev/null
done
cd ..
rm -rf $t
echo "Done! A list of copied files has been created in $n.list for eventual deletion." 
echo "(Warning! This may include files not safe for deletion. Always check.)"
exit 0
