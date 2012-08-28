# vim: sw=4:ts=4:et
#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.


%global homedir %{_datarootdir}/%{name}

Name:          runcible
Summary:       A gem to expose Pulp's juiciest parts.
Group:         Applications/System
License:       MIT
Version:       0.1.0
Release:       1%{?dist}
Source0:       %{name}-%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:     noarch

%description
A gem to expose Pulp's juiciest parts.

%prep
%setup -q 

%build

%install
rm -rf $RPM_BUILD_ROOT
install -m0755 -d %{buildroot}%{homedir}

%clean
rm -rf $RPM_BUILD_ROOT

%files 
%defattr(755, root, root)
%{homedir}
%doc README.md LICENSE

%changelog
