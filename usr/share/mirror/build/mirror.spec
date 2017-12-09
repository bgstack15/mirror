Summary: Mirror
Name: mirror
Version: 1.1
Release: 6
License: CC BY-SA 4.0
Group: Applications/System
Source: mirror.tgz
URL: bgstack15@gmail.com
#Distribution:
#Vendor:
Packager: Bgstack15 <bgstack15@gmail.com>
Buildarch: noarch
Requires(pre): bgscripts-core >= 1.1-28
Requires: httpd >= 2.2

%description
Mirror is the rpm package for the official albion320.no-ip.biz installation. 

%prep
%setup

%build

%install
rsync -a . %{buildroot}/

%clean
rm -rf ${buildroot}

%pre

%post

%preun

%files
%dir /etc/mirror
%dir /usr/share/mirror
%dir /usr/share/mirror/build
%dir /usr/share/mirror/inc
%dir /usr/share/mirror/examples
%dir /usr/share/mirror/examples/rpm
%dir /usr/share/mirror/examples/tar
%dir /usr/share/mirror/examples/deb
%dir /usr/share/mirror/examples/sites
%dir /usr/share/mirror/scripts
%config /etc/cron.d/mirror.cron
%config /etc/mirror/mirror.conf
%config /etc/mirror/deploy.conf
%config /etc/httpd/conf.d/local_mirror.conf
/etc/httpd/conf.d/local_mirror-ssl.cnf
%config %attr(440, root, root) /etc/sudoers.d/50_mirror-sudo
%verify(link) /usr/local/bin/deploy
%doc %attr(444, -, -) /usr/share/mirror/build/files-for-versioning.txt
/usr/share/mirror/build/localize_git.sh
/usr/share/mirror/build/get-files
%doc %attr(444, -, -) /usr/share/mirror/build/scrub.txt
/usr/share/mirror/build/mirror.spec
/usr/share/mirror/build/pack
/usr/share/mirror/inc/rsync
/usr/share/mirror/mirror-master.sh
/usr/share/mirror/doc
/usr/share/mirror/examples/FOOTER.html
/usr/share/mirror/examples/HEADER.html
/usr/share/mirror/examples/favicon.png
/usr/share/mirror/examples/rpm/FOOTER.html
/usr/share/mirror/examples/rpm/HEADER.html
/usr/share/mirror/examples/rpm/smith122rpm.repo
/usr/share/mirror/examples/rpm/update-smith122rpm.sh
/usr/share/mirror/examples/favicon.ico
/usr/share/mirror/examples/tar/update-smith122tar.sh
/usr/share/mirror/examples/deb/FOOTER.html
/usr/share/mirror/examples/deb/smith122deb.gpg
/usr/share/mirror/examples/deb/smith122deb.list
/usr/share/mirror/examples/deb/HEADER.html
/usr/share/mirror/examples/deb/update-smith122deb.sh
%config /usr/share/mirror/examples/sites/zz_proxy.conf
%config /usr/share/mirror/scripts/ssh
%config /usr/share/mirror/scripts/fedora-updates
%config /usr/share/mirror/scripts/centos
%config /usr/share/mirror/scripts/rsyslog
%config /usr/share/mirror/scripts/ubuntu
%config /usr/share/mirror/scripts/old-scripts.tgz
%config /usr/share/mirror/scripts/linuxmint-repos
%config /usr/share/mirror/scripts/fedora-epel
%config /usr/share/mirror/scripts/fedora-releases
%config /usr/share/mirror/scripts/libreoffice
%config /usr/share/mirror/scripts/ubuntu-releases
%config /usr/share/mirror/scripts/putty
%config /usr/share/mirror/scripts/linuxmint-isos
/usr/share/mirror/deploy.sh
%doc %attr(444, -, -) /usr/share/doc/mirror/README.txt
%doc %attr(444, -, -) /usr/share/doc/mirror/packaging.txt
%doc %attr(444, -, -) /usr/share/doc/mirror/version.txt
/usr/share/httpd/icons/rpm.png
/usr/share/httpd/icons/deb.png
/usr/share/httpd/icons/repo.png

%changelog
* Sat Dec  9 2017 B Stack <bgstack15@gmail.com> 1.1-6
- Updated content. See doc/README.txt.

* Sat Jul 22 2017 B Stack <bgstack15@gmail.com> 1.1-5
- Rearranged directory structure to match current bgscripts standard.
- Updated content. See doc/README.txt.
