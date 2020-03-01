[![forthebadge](https://forthebadge.com/images/badges/designed-in-ms-paint.svg)](https://forthebadge.com) [![forthebadge](https://forthebadge.com/images/badges/ages-12.svg)](https://forthebadge.com) [![forthebadge](https://forthebadge.com/images/badges/gluten-free.svg)](https://forthebadge.com)

# debinst

Debian (dpkg) package installer for Linux distributions with no dpkg/apt.
Debinst does not handle dependencies, but it executes post-install script if it exists.   
The code is kind of dirty.

## Usage
debinst [install|remove|list] {PACKAGE.deb}
Install will attempt to install the .deb package, remove will take a fuzzy search argument for all installed packages and attempt to remove them and their files based on their `.list` file. `.list` files are now stored in /var/debinst/lists.

List will output all installed .deb packages based on the .list files within the lists directory.

## Log files / uninstalling packages
This script leaves 1 to 2 files around.  
After installing `package.deb`, a `package.deb.list` with the list of all the installed files will be created in `/var/debinst/lists`.

`package.postinst.log` will be created in /var/debinst/logs if the post-install script exits with an error.  

## Todo
* Add a -f switch for overriding (or not) files.
* Check if the .deb is a good package before installing.

## License
See [UNLICENSE](UNLICENSE)
