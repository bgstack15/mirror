#!/bin/sh

# working directory
repodir=/mnt/mirror/bgscripts/
cd ${repodir}
chmod 0644 *rpm 1>/dev/null 2>&1

# create the package index
createrepo .
