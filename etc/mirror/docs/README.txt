File: etc/mirror/README.txt
Package: mirror 1.0-6
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
/etc/httpd/sites/mirror.conf
/etc/mirror/inc/rsync
/etc/mirror/mirror.conf

Select a storage directory. On the EXAMPLE mirror, we used an nfs mount for multiple locations.
--- BEGIN excerpt from mirror.example.com:/etc/fstab
linux-nfs2.example.com:/vol/linux_mirror    /mnt/realmirror nfs     defaults,uid=1539249479 0 0
/mnt/realmirror/mirror  /mnt/mirror                     none    bind    0 0
/mnt/mirror             /var/www/html/mirror.example.com    none    bind    0 0
--- END

## Scripts to run
The files called by mirror-master are the ones that actually do the source and target selection and file operations. By default they are located in /etc/mirror/scripts/
To enable a script, you must mark the executable flag:
chmod +x /etc/mirror/scripts/filetostart

It is recommended to start with certain ones enabled. You can use this command:
chmod +x /etc/mirror/scripts/{centos,fedora-epel,fedora-releases,fedora-updates,libreoffice,putty,ssh,ubuntu,ubuntu-releases}

## Configuring the web server
Included in this package are some apache configs.
For a nice intro page, a template is provided at /etc/mirror/inc/HEADER.html

## Maintaining your mirror server
Fedora only keeps current the two latest versions.
Ubuntu keeps certain versions current: check http://releases.ubuntu.com/ for which versions.

### USAGE BLOCK
usage: mirror-master.sh [-duV] [ -f | --file /etc/mirror/mirror.conf ] [ --scriptsdir /etc/mirror/scripts ] [ scriptname ]
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

### CHANGELOG
1.0-2 2016-06-10
uses config file /etc/mirror/mirror.conf 

1.0-3 2016-07-14
added supplementary script /etc/mirror/inc/deploy.sh
New feature: deploy
See its config file /etc/mirror/inc/deploy.conf

2016-10-28 mirror 1.0-4
Adding elemants for safe publishing on github
Added repos for linuxmint

2016-11-11 mirror 1.0-5
adding favicon, licensed CC BY 3.0 by Lorc <http://lorcblog.blogspot.com/>

2017-01-11 mirror-1.0-6
Updated all scripts for the bgscripts-1.1-28 directory migration to /usr/share/bgscripts
