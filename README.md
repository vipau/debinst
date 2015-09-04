# debinst
Debian (dpkg) package installer for Linux distributions with no dpkg/apt  
Debinst does not handle dependencies, but it executes post-install script if it exists.   
The code is kind of dirty.  

## Usage
[debinst.sh](debinst.sh) takes one argument only, the filename (ending in .deb)  
`./debinst /path/to/package.deb`

## Log files / uninstalling packages
This script leaves 1 to 2 files around.  
After installing `package.deb`, a `package.deb.list` with the list of all the installed files will be created.  
This is useful in case of uninstall, or to check for successful install.  
`postinst.log` will be created if the post-install script exits with an error.   
To uninstall a package, remove all the files contained in the .list file. If you already had a file and the package owerwrote it, you **will lose** it by doing this. Check the list first. (see todo)  

## Todo
* Add a -f switch for overriding (or not) files
* Check if the .deb is a good package before installing.
* Add an uninstaller.

## License
See [UNLICENSE](UNLICENSE)
