Summary: Mirror
Name: mirror
Version: 1.1
Release: 5
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
%dir /usr/share/mirror/examples
%dir /usr/share/mirror/examples/sites
%dir /usr/share/mirror/examples/deb
%dir /usr/share/mirror/examples/rpm
%dir /usr/share/mirror/inc
%dir /usr/share/mirror/docs
%dir /usr/share/mirror/scripts
%config /etc/sudoers.d/50_mirror-sudo
%config /etc/cron.d/mirror.cron
%config /etc/httpd/conf.d/local_mirror.conf
/etc/httpd/conf.d/local_mirror-ssl.cnf
%config /etc/mirror/mirror.conf
%config /etc/mirror/deploy.conf
/usr/share/httpd/icons/rpm.png
/usr/share/httpd/icons/repo.png
/usr/share/httpd/icons/deb.png
/usr/share/mirror/examples/FOOTER.html
/usr/share/mirror/examples/favicon.png
%config /usr/share/mirror/examples/sites/zz_proxy.conf
/usr/share/mirror/examples/favicon.ico
/usr/share/mirror/examples/HEADER.html
/usr/share/mirror/examples/deb/FOOTER.html
/usr/share/mirror/examples/deb/smith122deb.list
/usr/share/mirror/examples/deb/HEADER.html
/usr/share/mirror/examples/deb/smith122deb.gpg
/usr/share/mirror/examples/deb/update-smith122deb.sh
/usr/share/mirror/examples/rpm/FOOTER.html
/usr/share/mirror/examples/rpm/HEADER.html
/usr/share/mirror/examples/rpm/smith122rpm.repo
/usr/share/mirror/examples/rpm/update-smith122rpm.sh
/usr/share/mirror/inc/get-files
/usr/share/mirror/inc/get-files-core
/usr/share/mirror/inc/rsync
/usr/share/mirror/inc/localize_git.sh
%doc %attr(444, -, -) /usr/share/mirror/inc/scrub.txt
/usr/share/mirror/inc/pack
%doc %attr(444, -, -) /usr/share/mirror/docs/files-for-versioning.txt
%doc %attr(444, -, -) /usr/share/mirror/docs/packaging.txt
/usr/share/mirror/docs/mirror.spec
%doc %attr(444, -, -) /usr/share/mirror/docs/README.txt
/usr/share/mirror/mirror-master.sh
%config /usr/share/mirror/scripts/fedora-updates
%config /usr/share/mirror/scripts/libreoffice
%config /usr/share/mirror/scripts/ubuntu-releases
%config /usr/share/mirror/scripts/putty
%config /usr/share/mirror/scripts/ssh
%config /usr/share/mirror/scripts/ubuntu
%config /usr/share/mirror/scripts/fedora-releases
%config /usr/share/mirror/scripts/centos
%config /usr/share/mirror/scripts/old-scripts.tgz
%config /usr/share/mirror/scripts/fedora-epel
%config /usr/share/mirror/scripts/linuxmint-isos
%config /usr/share/mirror/scripts/rsyslog
%config /usr/share/mirror/scripts/linuxmint-repos
/usr/share/mirror/deploy.sh
%verify(link) /usr/local/bin/deploy
