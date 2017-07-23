#!/bin/sh
# update-tar.sh

# Prepare directory and files
repodir=/mnt/public/www/smith122/repo/tar/
ownership="apache:admins"
filetypes="tar"
find "${repodir}" -exec chown "${ownership}" {} + 1>/dev/null 2>&1
find "${repodir}" -type f -exec chmod "0644" {} + 1>/dev/null 2>&1
find "${repodir}" -type d -exec chmod "0755" {} + 1>/dev/null 2>&1
chmod 0754 "$0"
restorecon -RF "${repodir}"

# Prepare repo for tar
cd "${repodir}"
