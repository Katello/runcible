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

%global gem_name runcible

%global gem_dir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gem_instdir %{gem_dir}/gems/%{gem_name}-%{version}

%if 0%{?rhel} == 6 || 0%{?fedora} < 17
%define rubyabi 1.8
%else
%define rubyabi 1.9.1
%endif

%if 0%{?rhel} == 6
%global gem_dir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gem_docdir %{gem_dir}/doc/%{gem_name}-%{version}
%global gem_cache %{gem_dir}/cache/%{gem_name}-%{version}.gem
%global gem_spec %{gem_dir}/specifications/%{gem_name}-%{version}.gemspec
%global gem_instdir %{gem_dir}/gems/%{gem_name}-%{version}
%endif

%if 0%{?fedora}
BuildRequires: rubygems-devel
%endif

Name:           rubygem-%{gemname}
Summary:        A gem exposing Pulp's juiciest parts
Group:          Applications/System
License:        MIT
Version:        0.0.6
Release:        1%{?dist}
Source0:        %{gem_name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       ruby(abi) = %{rubyabi}
Requires:       ruby(rubygems) 
Requires:       rubygem(json) 
Requires:       rubygem(rest-client) >= 1.6.1
Requires:       rubygem(oauth) 
BuildRequires:  ruby(abi) = %{rubyabi}
BuildRequires:  ruby(rubygems) 
BuildRequires:  ruby 
BuildArch:      noarch
Provides:       rubygem(%{gemname}) = %{version}

%description
A gem to expose Pulp's juiciest parts.

%prep
gem unpack %{SOURCE0}
%setup -q -D -T -n %{gem_name}-%{version}

gem spec %{SOURCE0} -l --ruby > %{gem_name}.gemspec

%build
mkdir -p ./%{gemdir}
gem build %{gem_name}.gemspec

gem install -V \
    --local \
    --install-dir ./%{gem_dir} \
    --bindir ./%{_bindir}
    --force \
    %{gem_name}-%{version}.gem

%install
mkdir -p %{buildroot}%{gemdir}
cp -a ./%{gem_dir}/* %{buildroot}%{gem_dir}/

%files
%dir %{geminstdir}
%{geminstdir}/lib
%exclude %{gem_cache}
%{gem_spec}

%changelog
* Fri Sep 14 2012 Eric D. Helms <ehelms@redhat.com> 0.0.6-1
- new package built with tito

* Fri Sep 14 2012 Eric D. Helms <ehelms@redhat.com> 0.0.3-1
- new package built with tito

