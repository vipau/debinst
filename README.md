# debinst
Debian (dpkg) package installer for Linux distributions with no dpkg/apt  
Debinst does not handle dependencies, but it executes post-install script.   
The code is kind of dirty.  

## Usage
`debinst` takes one argument only, the filename (ending in .deb)  
`./debinst /path/to/package.deb`

## Leftovers
This script leaves 1 to 2 files around.  
After installing `package.deb`, a `package.deb.list` with the list of all the installed files will be created.  
This is useful in case of uninstall, or to check for successful install.  
`postinst.log` will be created if the post-install script exits with an error.   

## License
See `UNLICENSE`  
