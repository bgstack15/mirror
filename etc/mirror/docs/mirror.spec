#
# spec file for Mirror compiled by hand
Summary: Mirror
Name: mirror
Version: 1.0
Release: 4
License: CC BY-SA 4.0
Group: Applications/System
Source: mirror.tgz
URL: bgstack15@gmail.com
#Distribution:
#Vendor:
Packager: Bgstack15 <bgstack15@gmail.com>
Buildarch: noarch
PreReq: bgscripts >= 1.1-17
Requires: httpd >= 2.2

%description
Mirror is the rpm package for the official mirror.example.com installation. 

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
%config /etc/sudoers.d/50_mirror-sudo
%config /etc/cron.d/mirror.cron
/etc/mirror/mirror-master.sh
%doc %attr(444, -, -) /etc/mirror/README.txt
/etc/mirror/scripts/ssh
/etc/mirror/scripts/libreoffice
/etc/mirror/scripts/linuxmint-repos
/etc/mirror/scripts/ubuntu
/etc/mirror/scripts/putty
/etc/mirror/scripts/rsyslog
/etc/mirror/scripts/centos
/etc/mirror/scripts/fedora-epel
/etc/mirror/scripts/ubuntu-releases
/etc/mirror/scripts/linuxmint-isos
/etc/mirror/scripts/fedora-releases
/etc/mirror/scripts/fedora-updates
/etc/mirror/docs/debian/postinst
/etc/mirror/docs/debian/conffiles
/etc/mirror/docs/debian/prerm
/etc/mirror/docs/debian/postrm
/etc/mirror/docs/debian/control
/etc/mirror/docs/debian/preinst
/etc/mirror/docs/mirror.spec
/etc/mirror/inc/scrub.py
/etc/mirror/inc/scrub.pyc
/etc/mirror/inc/scrub.pyo
%config /etc/mirror/inc/deploy.conf
/etc/mirror/inc/localize_git.sh
/etc/mirror/inc/deploy.sh
%doc %attr(444, -, -) /etc/mirror/inc/scrub.txt
/etc/mirror/inc/rsync
%doc %attr(444, -, -) /etc/mirror/packaging.txt
/etc/mirror/examples/HEADER.html
/etc/mirror/examples/example-debian/example-debian.list
/etc/mirror/examples/example-debian/update-example-debian.sh
/etc/mirror/examples/example-debian/FOOTER.html
/etc/mirror/examples/example-debian/HEADER.html
/etc/mirror/examples/example-debian/example-debian.gpg
/etc/mirror/examples/example-rpm/FOOTER.html
/etc/mirror/examples/example-rpm/HEADER.html
/etc/mirror/examples/example-rpm/example-rpm.repo
/etc/mirror/examples/example-rpm/update-example-rpm.sh
%config /etc/mirror/mirror.conf
%config /etc/httpd/sites/10.1.8.63.conf
%config /etc/httpd/sites/mntscripts.conf
%config /etc/httpd/sites/mirror.conf
%verify(link) /usr/local/bin/deploy
/usr/share/httpd/icons/repo.png
/usr/share/httpd/icons/rpm.png
