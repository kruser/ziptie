Summary: ZipTie EMS Server
Name: ziptie-server
Version: %version
Release: %release
Source0: %archive
License: MPL
Group: System/Servers
BuildArch: i386
BuildRoot: /var/tmp/%{name}-buildroot
Requires: %require

%description
ZipTie is a framework for Network Inventory Management.
%prep
%setup -q -n ziptie-server
%build
############################################################
# INSTALL
############################################################
%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT/usr/share/ziptie-server

cp -v -R . $RPM_BUILD_ROOT/usr/share/ziptie-server/

############################################################
# PRE-INSTALL
############################################################
%pre
useradd -r --shell /bin/false ziptie

############################################################
# POST-INSTALL
############################################################
%post
ln -s /usr/share/ziptie-server/ztserver /etc/rc.d/init.d/ziptie-server
chmod +x /usr/share/ziptie-server/ztserver
chmod +x /usr/share/ziptie-server/ztwrapper/linux/ztwrapper

cd /etc/rc.d/rc0.d
ln -s ../init.d/ziptie-server K05ziptie-server

cd /etc/rc.d/rc5.d
ln -s ../init.d/ziptie-server S95ziptie-server

perl /usr/share/ziptie-server/perlcheck.pl

service ziptie-server start

############################################################
# PRE-UNINSTALL
############################################################
%preun
service ziptie-server stop

############################################################
# UNINSTALL
############################################################
%postun
userdel ziptie

rm /etc/rc.d/rc0.d/K05ziptie-server
rm /etc/rc.d/rc5.d/S95ziptie-server
rm /etc/rc.d/init.d/ziptie-server

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,ziptie,ziptie)

/usr/share/ziptie-server
