#!/bin/sh
# update-deb.sh

# Prepare directory and files
repodir=/mnt/public/www/smith122/repo/deb/
ownership="apache:admins"
filetypes="deb"
find "${repodir}" -exec chown "${ownership}" {} + 1>/dev/null 2>&1
find "${repodir}" -type f -exec chmod "0644" {} + 1>/dev/null 2>&1
find "${repodir}" -type d -exec chmod "0755" {} + 1>/dev/null 2>&1
chmod 0754 "$0"
restorecon -RF "${repodir}"

# Prepare repo for deb
cd "${repodir}"
dpkg-scanpackages -m . > Packages
gzip -9c < Packages > Packages.gz

# create the Release file
PKGS="$(wc -c Packages)"
PKGS_GZ="$(wc -c Packages.gz)"
cat <<EOF > Release
Architectures: all
Date: $(date -u '+%a, %d %b %Y %T %Z')
MD5Sum:
 $(md5sum Packages  | cut -d" " -f1) $PKGS
 $(md5sum Packages.gz  | cut -d" " -f1) $PKGS_GZ
SHA1:
 $(sha1sum Packages  | cut -d" " -f1) $PKGS
 $(sha1sum Packages.gz  | cut -d" " -f1) $PKGS_GZ
SHA256:
 $(sha256sum Packages | cut -d" " -f1) $PKGS
 $(sha256sum Packages.gz | cut -d" " -f1) $PKGS_GZ
EOF
gpg --batch --yes --passphrase-file /root/.gnupg/linuxadmin -abs -o Release.gpg Release
