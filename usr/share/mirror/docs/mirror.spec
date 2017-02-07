Summary: Mirror
Name: mirror
Version: 1.0
Release: 8
License: CC BY-SA 4.0
Group: Applications/System
Source: mirror.tgz
URL: bgstack15@gmail.com
#Distribution:
#Vendor:
Packager: Bgstack15 <bgstack15@gmail.com>
Buildarch: noarch
PreReq: bgscripts >= 1.1-28
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
%config /etc/mirror/deploy.conf
%config /etc/mirror/mirror.conf
%config /etc/httpd/conf.d/local_mirror.conf
%verify(link) /usr/local/bin/deploy
/usr/share/mirror/mirror-master.sh
%config /usr/share/mirror/scripts/ssh
%config /usr/share/mirror/scripts/libreoffice
%config /usr/share/mirror/scripts/linuxmint-repos
%config /usr/share/mirror/scripts/ubuntu
%config /usr/share/mirror/scripts/putty
%config /usr/share/mirror/scripts/rsyslog
%config /usr/share/mirror/scripts/centos
%config /usr/share/mirror/scripts/fedora-epel
%config /usr/share/mirror/scripts/old-scripts.tgz
%config /usr/share/mirror/scripts/ubuntu-releases
%config /usr/share/mirror/scripts/linuxmint-isos
%config /usr/share/mirror/scripts/fedora-releases
%config /usr/share/mirror/scripts/fedora-updates
/usr/share/mirror/docs/debian/postinst
/usr/share/mirror/docs/debian/conffiles
/usr/share/mirror/docs/debian/prerm
/usr/share/mirror/docs/debian/postrm
/usr/share/mirror/docs/debian/control
/usr/share/mirror/docs/debian/preinst
%doc %attr(444, -, -) /usr/share/mirror/docs/README.txt
/usr/share/mirror/docs/mirror.spec
%doc %attr(444, -, -) /usr/share/mirror/docs/packaging.txt
%doc %attr(444, -, -) /usr/share/mirror/docs/files-for-versioning.txt
/usr/share/mirror/deploy.sh
/usr/share/mirror/inc/pack
/usr/share/mirror/inc/localize_git.sh
%doc %attr(444, -, -) /usr/share/mirror/inc/scrub.txt
/usr/share/mirror/inc/rsync
/usr/share/mirror/examples/favicon.ico
/usr/share/mirror/examples/FOOTER.html
/usr/share/mirror/examples/HEADER.html
%config /usr/share/mirror/examples/sites/zz_proxy.conf
%config /usr/share/mirror/examples/sites/10.1.8.63.conf
%config /usr/share/mirror/examples/sites/mntscripts.conf
%config /usr/share/mirror/examples/sites/mirror.conf
/usr/share/mirror/examples/example-debian/example-debian.list
/usr/share/mirror/examples/example-debian/update-example-debian.sh
/usr/share/mirror/examples/example-debian/FOOTER.html
/usr/share/mirror/examples/example-debian/HEADER.html
/usr/share/mirror/examples/example-debian/example-debian.gpg
/usr/share/mirror/examples/example-rpm/FOOTER.html
/usr/share/mirror/examples/example-rpm/HEADER.html
/usr/share/mirror/examples/example-rpm/example-rpm.repo
/usr/share/mirror/examples/example-rpm/update-example-rpm.sh
/usr/share/mirror/examples/favicon.png
/usr/share/httpd/icons/repo.png
/usr/share/httpd/icons/rpm.png
