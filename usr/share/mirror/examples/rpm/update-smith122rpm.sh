#!/bin/sh
# update-rpm.sh

# Prepare directory and files
repodir=/mnt/public/www/smith122/repo/rpm/
ownership="apache:admins"
filetypes="rpm"
find "${repodir}" -exec chown "${ownership}" {} + 1>/dev/null 2>&1
find "${repodir}" -type f -exec chmod "0664" {} + 1>/dev/null 2>&1
find "${repodir}" -type d -exec chmod "0775" {} + 1>/dev/null 2>&1
chmod 0754 "$0"
restorecon -RF "${repodir}"

# Prepare repo for rpm
cd ${repodir}
createrepo .
