File: /usr/share/mirror/docs/README.txt
Package: mirror
Author: bgstack15@gmail.com
Startdate: 2016-06-08
Title: Readme file for mirror
Purpose: All packages should come with a readme
Usage: Read it.
Reference: README.txt
Improve:
Document: Below this line

### WELCOME

mirror is basically a collection of scripts that provide the sync instructions to make a local repository of software. 

## Steps to take before using mirror for the first time
Configure these files:
/etc/mirror/mirror.conf
/etc/httpd/conf.d/mirror.conf
/usr/share/mirror/inc/rsync

Select a storage directory. This one is preconfigured for /mnt/public/www/smith122/repo

Generate a GPG key and modify update-smith122deb.sh to use it.

## Scripts to run
The files called by mirror-master are the ones that actually do the source and target selection and file operations. By default they are located in /etc/mirror/scripts/
To enable a script, you must mark the executable flag:
chmod +x /etc/mirror/scripts/filetostart

It is recommended to start with certain ones enabled. You can use this command:
chmod +x /etc/mirror/scripts/{centos,fedora-epel,fedora-releases,fedora-updates,libreoffice,putty,ssh,ubuntu,ubuntu-releases}

## Configuring the web server
Included in this package are some apache configs.
For a nice intro page, a template is provided at /usr/share/mirror/inc/HEADER.html

## Maintaining your mirror server
Fedora only keeps current the two latest versions.
Ubuntu keeps certain versions current: check http://releases.ubuntu.com/ for which versions.

### USAGE BLOCK
usage: mirror-master.sh [-duV] [ -f | --file /etc/mirror/mirror.conf ] [ --scriptsdir /usr/share/mirror/scripts ] [ scriptname ]
version ${mirrormasterversion}
 -d debug   Show debugging info, including parsed variables.
 -u usage   Show this usage block.
 -V version Show script version number.
 -f file    Use specified config file. Default is /etc/mirror/mirror.conf
    --scriptsdir    Use specified scripts directory. Will override anything in the called conf file
Return values:
0 Normal
1 Help or version info displayed
2 mirror-master is already running
3 Unable to modify important file
4 Unable to find dependency
5 Not run as root or sudo
Examples:
   mirror-master.sh centos
      This command will run only the scripts/centos file.
   mirror-master.sh centos putty
      This command will run only centos and putty files.
   mirror-master.sh
      This command will run all files with o+x perms in scriptsdir directory.

### REFERENCE

### CREDITS
Favicon by Lorc (http://lorcblog.blogspot.com/)
http://game-icons.net/
License: CC-BY 3.0
Deb icon by franksouza183 (http://www.iconarchive.com/artist/franksouza183.html)
http://www.iconarchive.com/show/fs-icons-by-franksouza183/Mimetypes-deb-icon.html
License: GPL

Rpm icon by Saki (http://www.iconarchive.com/artist/saki.html)
http://www.iconarchive.com/show/nuoveXT-icons-by-saki/Mimetypes-rpm-icon.html
License: GPL

Repo icon adapted from https://commons.wikimedia.org/wiki/File:Documents_icon_-_noun_project_5020.svg
Author: Dmitry Baranovskiy (http://thenounproject.com/DmitryBaranovskiy/)
License: CC-BY 3.0

### CHANGELOG
1.0-2 2016-06-10
uses config file /etc/mirror/mirror.conf 

1.0-3 2016-07-14
added supplementary script /etc/mirror/inc/deploy.sh
New feature: deploy
See its config file /etc/mirror/inc/deploy.conf

2016-10-28 mirror 1.0-4
Adding elements for safe publishing on github
Added repos for linuxmint

2016-11-11 mirror 1.0-5
adding favicon, licensed CC BY 3.0 by Lorc <http://lorcblog.blogspot.com/>

2017-01-11 mirror-1.0-6
Updated all scripts for the bgscripts-1.1-28 directory migration to /usr/share/bgscripts

2017-02-06 mirror-1.0-7
Rearranged directory structure to comply with FHS 3.0
Included a zz_proxy.conf example
Added deploy.sh --noupdate option

2017-02-07 mirror-1.0-8
Fixed mirror.conf to point to correct directory of /usr/share/mirror/scripts
Added contents of /usr/share/mirror/scripts as %config directives in ./pack spec instructions
Moved httpd/sites contents to /usr/share/mirror/examples/sites so it will not overwrite any existing files. These are just examples and should be deployed manually.
Fixed dependency to bgscripts-core

2017-02-08 mirror-1.0-9
Updated scripts to use /usr/share/mirror/inc/rsync script

2017-03-03 mirror-1.1-1
Adapted for smith122 repos

2017-03-04 mirror-1.1-2
Fixed directories' ownership to this package so they are removed when the package is removed.

2017-04-04 mirror-1.1-3
Fixed deploy.sh to have more consistent and useful error messages
Fixed deploy.conf to point to /srv/science for everything
Changed deploy.conf to use package directories for deployment

2017-05-20 mirror-1.1-4
- Adapted new icons for rpm, deb, and repos.
- Updated directories for storage1 in the Mersey network.
