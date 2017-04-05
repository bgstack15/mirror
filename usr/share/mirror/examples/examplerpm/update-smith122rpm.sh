#!/bin/sh

# working directory
repodir=/srv/science/smith122/repo/rpm/
cd ${repodir}
chmod 0644 *rpm 1>/dev/null 2>&1
restorecon -RF "${repodir}"

# create the package index
createrepo .
