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

%global gemname runcible

%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}
%global rubyabi 1.8

Name:           rubygem-%{gemname}
Summary:        A gem to expose Pulp's juiciest parts.
Group:          Applications/System
License:        MIT
Version:        0.0.3
Release:        1%{?dist}
Source0:        http://rubygems.org/gems/%{gemname}-%{version}.gem
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       ruby(abi) = %{rubyabi}
Requires:       ruby(rubygems) 
Requires:       rubygem(json) 
Requires:       rubygem(rest-client) >= 1.6.1
Requires:       rubygem(oauth) 
Requires:       ruby 
BuildRequires:  ruby(abi) = %{rubyabi}
BuildRequires:  ruby(rubygems) 
BuildRequires:  ruby 
BuildArch:      noarch
Provides:       rubygem(%{gemname}) = %{version}

%description
A gem to expose Pulp's juiciest parts.

%prep
%setup -q -c -T
mkdir -p .%{gemdir}
gem install --local --install-dir .%{gemdir} \
            --force %{SOURCE0}

%build

%install
mkdir -p %{buildroot}%{gemdir}
cp -a .%{gemdir}/* \
        %{buildroot}%{gemdir}/


%files
%dir %{geminstdir}
%{geminstdir}/lib
%exclude %{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec

%changelog
* Fri Sep 14 2012 Eric D. Helms <ehelms@redhat.com> 0.0.3-1
- new package built with tito

