#!/bin/sh

# working directory
repodir=/mnt/public/www/smith122/repo/deb/
cd ${repodir}
chmod 0644 *deb 1>/dev/null 2>&1
restorecon -RF "${repodir}"

# create the package index
dpkg-scanpackages -m . > Packages
cat Packages | gzip -9c > Packages.gz

# create the Release file
#Date: $(date -R)
PKGS=$(wc -c Packages)
PKGS_GZ=$(wc -c Packages.gz)
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
