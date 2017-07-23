#!/bin/sh
cd /mnt/public/www/smith122/repo/tar
chown -R apache:apache .
find . -type f -regextype grep \( -regex '.*\.tar' -o -regex '.*\.tgz' -o -regex '.*\.gz' \) -exec chmod '-x' {} \; ;
chmod +x "$0"
