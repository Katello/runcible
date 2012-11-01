# vim: sw=4:ts=4:et
#
# Copyright 2011 Red Hat, Inc.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

%global gem_name runcible

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

Name:           rubygem-%{gem_name}
Summary:        A gem exposing Pulp's juiciest parts
Group:          Applications/System
License:        MIT
Version:        0.1.2
Release:        1%{?dist}
URL:            https://github.com/Katello/runcible
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{gem_name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       ruby(abi) = %{rubyabi}
Requires:       ruby(rubygems) 
Requires:       rubygem(json) 
Requires:       rubygem(rest-client) >= 1.6.1
Requires:       rubygem(oauth) 
Requires:       rubygem(activesupport) = 3.0.10
Requires:       rubygem(i18n) >= 0.5.0
BuildRequires:  ruby(abi) = %{rubyabi}
BuildRequires:  ruby(rubygems) 
BuildArch:      noarch
Provides:       rubygem(%{gem_name}) = %{version}

%description
A gem to expose Pulp's juiciest parts.


%prep
%setup -q

%build
gem build %{gem_name}.gemspec

%install
mkdir -p %{buildroot}%{gem_dir}

gem install \
    --local \
    --install-dir %{buildroot}%{gem_dir} \
    --force \
    %{gem_name}-%{version}.gem

rm -rf %{buildroot}%{gem_instdir}/.yardoc

%files
%{gem_instdir}/
%{gem_instdir}/lib
%exclude %{gem_cache}
%{gem_spec}
%doc LICENSE


%package doc
BuildArch:  noarch
Requires:   %{name} = %{version}-%{release}
Summary:    Documentation for rubygem-%{gem_name}

%description doc
This package contains documentation for rubygem-%{gem_name}

%files doc
%doc %{gem_docdir}

%changelog
* Thu Oct 25 2012 Eric D. Helms <ehelms@redhat.com> 0.1.2-1
- Version bump. (ehelms@redhat.com)
- Updates README indentation for code blocks and moves all Copyrights to Red
  Hat. (ehelms@redhat.com)
- Updates README to include configuration and examples. (ehelms@redhat.com)
- Updates to add bold emphasis to pulp version in README. (ehelms@redhat.com)
- Adds Rake task to grab pulp version and input to the README.
  (ehelms@redhat.com)
- Adds missing errata test and cassette. (ehelms@redhat.com)
- Moves helpers to be under test/support. (ehelms@redhat.com)
- Adds missing cassette file. (ehelms@redhat.com)
- Merge branch 'master' of github.com:Katello/runcible (ehelms@redhat.com)
- Merge pull request #13 from parthaa/consumer-groups (ericdhelms@gmail.com)
- Initial set of runcible consumer group bindings (paji@redhat.com)
- Added  consumer tests for content install/update/uninstall (paji@redhat.com)
- Moves fixtures to be under test/fixtures instead of test/integration.
  (ehelms@redhat.com)
- Fixed repo sync schedule based tests (paji@redhat.com)
- Adding back previously deleted test files. (ehelms@redhat.com)
- Misc Fixes to get pulp artifacts running (paji@redhat.com)
- Patch to get all tests running right in live mode (paji@redhat.com)
- Tweaked the tests to pass in the 'none' mode (paji@redhat.com)
- Split up the extension/resources tests in  different files (paji@redhat.com)
- Fixed consumer unit tests based on comments offered in the pull
  (paji@redhat.com)
- Moved the binding methods to follow the runcible convention of separate calls
  (paji@redhat.com)
- Reverting a previous change on this file (paji@redhat.com)
- Merge branch 'master' into pulp-consumer-changes (paji@redhat.com)
- Added tests for consumer API (paji@redhat.com)
- Changes to deal with pulp-server-0.0.331-1.fc16.noarch (paji@redhat.com)
- Fixed notifications to work with the new pulp (paji@redhat.com)

* Tue Oct 16 2012 Eric D. Helms <ehelms@redhat.com> 0.1.1-1
- Version bump. (ehelms@redhat.com)

* Tue Oct 09 2012 Eric D. Helms <ehelms@redhat.com> 0.1.0-1
- Version bump. (ehelms@redhat.com)
- Updates README with Travis status and new test options. (ehelms@redhat.com)
- Removing puts in helper that are not quite helpful. (ehelms@redhat.com)
- Adds i18n for activesupport. (ehelms@redhat.com)
- Typo in Gemfile. (ehelms@redhat.com)
- Adds missing active_support requirement. (ehelms@redhat.com)
- Updates to testing to allow recorded and none modes to be run on a system
  without pulp installed.  Adds option to turn logging during testing off or
  on. (ehelms@redhat.com)
- Removes references to ruby-debug. (ehelms@redhat.com)
- Adds rake to Gemfile. (ehelms@redhat.com)
- Removes ruby-debug from Gemfile, adds none as the default test mode and adds
  a basic travis config file. (ehelms@redhat.com)
- merge conflicts (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- uncommenting some repo test code (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- fixing broken test (jsherril@redhat.com)
- cleaning up search tests (jsherril@redhat.com)
- pulpv2 - consumer - adding apis for repo binding and content actions
  (bbuckingham@redhat.com)
- moving repository test (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- adding distributions and other unit tests (jsherril@redhat.com)
- adding new ignore (jsherril@redhat.com)
- pulpv2 - adding retrieve all for users and re-organizing
  (jsherril@redhat.com)
- Merge pull request #5 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- adding testing for rpm/errata/category/group (jsherril@redhat.com)
- Revert "removing generate_metadata as it is not a valid option"
  (jsherril@redhat.com)
- adding units (jsherril@redhat.com)
- removing spaces (jsherril@redhat.com)
- removing generate_metadata as it is not a valid option (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- Merge pull request #4 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- pull request comment (jsherril@redhat.com)
- addressing pull request comments (jsherril@redhat.com)
- fixing return on publish_all extension (jsherril@redhat.com)
- new cassettes (jsherril@redhat.com)
- adding event notifiers to runcible (jsherril@redhat.com)
- cassette update (jsherril@redhat.com)
- adding extension test (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- moving some tests to their own vcr cassettes for isolation, also
  consolidating setups into before_suites (jsherril@redhat.com)
- reducing sleep time (jsherril@redhat.com)
- really adding None record type (jsherril@redhat.com)
- Small fix to get pulp repo test running (paji@redhat.com)
- addressing previous commits comments (jsherril@redhat.com)
- fixes #2 - fixing typo in gemspec (jsherril@redhat.com)
- Adding missing license (jsherril@redhat.com)
- updating readme to point to none mode (jsherril@redhat.com)
- updating vcr cassettes (jsherril@redhat.com)
- Moving with_indifferent_access to base (jsherril@redhat.com)
- removing unintentionally commented out section (jsherril@redhat.com)
- adding unit unassociation methods (jsherril@redhat.com)
- allowing None for record mode (jsherril@redhat.com)
- fixes for pull request (jsherril@redhat.com)
- Update to support proper get params with multiple values
  (jsherril@redhat.com)
- pulp v2 - consumer - initial changes for
  create/review/update/delete/profile/profile upload (bbuckingham@redhat.com)
- moving importers and distributors to their own files (jsherril@redhat.com)
- adding schedule extension and moviing requires (jsherril@redhat.com)
- adding new vcr data (jsherril@redhat.com)
- adding tests for repoistory schedules (jsherril@redhat.com)
- moving unit repo listing to runcible (jsherril@redhat.com)
- some task changes, properly implementing sync_status (jsherril@redhat.com)
- updated vcr data (jsherril@redhat.com)
- moving all unit_copy items to runcible (jsherril@redhat.com)
- new vcr data (jsherril@redhat.com)
- adding importer/distributor extensions and tests (jsherril@redhat.com)
- README update for tests (jsherril@redhat.com)
- adding importer and exporter objects (jsherril@redhat.com)
- Updates to re-scope from Pulp to Resources and from Pulp to Extensions and
  fit in line more with the directory structure. (ehelms@redhat.com)
- Version bump. (ehelms@redhat.com)

* Tue Oct 09 2012 Eric D. Helms <ehelms@redhat.com> 0.1.0-1
- Updates README with Travis status and new test options. (ehelms@redhat.com)
- Removing puts in helper that are not quite helpful. (ehelms@redhat.com)
- Adds i18n for activesupport. (ehelms@redhat.com)
- Typo in Gemfile. (ehelms@redhat.com)
- Adds missing active_support requirement. (ehelms@redhat.com)
- Updates to testing to allow recorded and none modes to be run on a system
  without pulp installed.  Adds option to turn logging during testing off or
  on. (ehelms@redhat.com)
- Removes references to ruby-debug. (ehelms@redhat.com)
- Adds rake to Gemfile. (ehelms@redhat.com)
- Removes ruby-debug from Gemfile, adds none as the default test mode and adds
  a basic travis config file. (ehelms@redhat.com)
- merge conflicts (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- uncommenting some repo test code (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- fixing broken test (jsherril@redhat.com)
- cleaning up search tests (jsherril@redhat.com)
- pulpv2 - consumer - adding apis for repo binding and content actions
  (bbuckingham@redhat.com)
- moving repository test (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- adding distributions and other unit tests (jsherril@redhat.com)
- adding new ignore (jsherril@redhat.com)
- pulpv2 - adding retrieve all for users and re-organizing
  (jsherril@redhat.com)
- Merge pull request #5 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- adding testing for rpm/errata/category/group (jsherril@redhat.com)
- Revert "removing generate_metadata as it is not a valid option"
  (jsherril@redhat.com)
- adding units (jsherril@redhat.com)
- removing spaces (jsherril@redhat.com)
- removing generate_metadata as it is not a valid option (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- Merge pull request #4 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- pull request comment (jsherril@redhat.com)
- addressing pull request comments (jsherril@redhat.com)
- fixing return on publish_all extension (jsherril@redhat.com)
- new cassettes (jsherril@redhat.com)
- adding event notifiers to runcible (jsherril@redhat.com)
- cassette update (jsherril@redhat.com)
- adding extension test (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- moving some tests to their own vcr cassettes for isolation, also
  consolidating setups into before_suites (jsherril@redhat.com)
- reducing sleep time (jsherril@redhat.com)
- really adding None record type (jsherril@redhat.com)
- Small fix to get pulp repo test running (paji@redhat.com)
- addressing previous commits comments (jsherril@redhat.com)
- fixes #2 - fixing typo in gemspec (jsherril@redhat.com)
- Adding missing license (jsherril@redhat.com)
- updating readme to point to none mode (jsherril@redhat.com)
- updating vcr cassettes (jsherril@redhat.com)
- Moving with_indifferent_access to base (jsherril@redhat.com)
- removing unintentionally commented out section (jsherril@redhat.com)
- adding unit unassociation methods (jsherril@redhat.com)
- allowing None for record mode (jsherril@redhat.com)
- fixes for pull request (jsherril@redhat.com)
- Update to support proper get params with multiple values
  (jsherril@redhat.com)
- pulp v2 - consumer - initial changes for
  create/review/update/delete/profile/profile upload (bbuckingham@redhat.com)
- moving importers and distributors to their own files (jsherril@redhat.com)
- adding schedule extension and moviing requires (jsherril@redhat.com)
- adding new vcr data (jsherril@redhat.com)
- adding tests for repoistory schedules (jsherril@redhat.com)
- moving unit repo listing to runcible (jsherril@redhat.com)
- some task changes, properly implementing sync_status (jsherril@redhat.com)
- updated vcr data (jsherril@redhat.com)
- moving all unit_copy items to runcible (jsherril@redhat.com)
- new vcr data (jsherril@redhat.com)
- adding importer/distributor extensions and tests (jsherril@redhat.com)
- README update for tests (jsherril@redhat.com)
- adding importer and exporter objects (jsherril@redhat.com)
- Updates to re-scope from Pulp to Resources and from Pulp to Extensions and
  fit in line more with the directory structure. (ehelms@redhat.com)
- Version bump. (ehelms@redhat.com)

* Tue Oct 09 2012 Eric D. Helms <ehelms@redhat.com> 0.1.0-1
- Version bump to 0.1 (ehelms@redhat.com)
- Removing puts in helper that are not quite helpful. (ehelms@redhat.com)
- Adds i18n for activesupport. (ehelms@redhat.com)
- Typo in Gemfile. (ehelms@redhat.com)
- Adds missing active_support requirement. (ehelms@redhat.com)
- Updates to testing to allow recorded and none modes to be run on a system
  without pulp installed.  Adds option to turn logging during testing off or
  on. (ehelms@redhat.com)
- Removes references to ruby-debug. (ehelms@redhat.com)
- Adds rake to Gemfile. (ehelms@redhat.com)
- Removes ruby-debug from Gemfile, adds none as the default test mode and adds
  a basic travis config file. (ehelms@redhat.com)
- merge conflicts (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- uncommenting some repo test code (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- fixing broken test (jsherril@redhat.com)
- cleaning up search tests (jsherril@redhat.com)
- pulpv2 - consumer - adding apis for repo binding and content actions
  (bbuckingham@redhat.com)
- moving repository test (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- adding distributions and other unit tests (jsherril@redhat.com)
- adding new ignore (jsherril@redhat.com)
- pulpv2 - adding retrieve all for users and re-organizing
  (jsherril@redhat.com)
- Merge pull request #5 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- adding testing for rpm/errata/category/group (jsherril@redhat.com)
- Revert "removing generate_metadata as it is not a valid option"
  (jsherril@redhat.com)
- adding units (jsherril@redhat.com)
- removing spaces (jsherril@redhat.com)
- removing generate_metadata as it is not a valid option (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- Merge pull request #4 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- pull request comment (jsherril@redhat.com)
- addressing pull request comments (jsherril@redhat.com)
- fixing return on publish_all extension (jsherril@redhat.com)
- new cassettes (jsherril@redhat.com)
- adding event notifiers to runcible (jsherril@redhat.com)
- cassette update (jsherril@redhat.com)
- adding extension test (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- moving some tests to their own vcr cassettes for isolation, also
  consolidating setups into before_suites (jsherril@redhat.com)
- reducing sleep time (jsherril@redhat.com)
- really adding None record type (jsherril@redhat.com)
- Small fix to get pulp repo test running (paji@redhat.com)
- addressing previous commits comments (jsherril@redhat.com)
- fixes #2 - fixing typo in gemspec (jsherril@redhat.com)
- Adding missing license (jsherril@redhat.com)
- updating readme to point to none mode (jsherril@redhat.com)
- updating vcr cassettes (jsherril@redhat.com)
- Moving with_indifferent_access to base (jsherril@redhat.com)
- removing unintentionally commented out section (jsherril@redhat.com)
- adding unit unassociation methods (jsherril@redhat.com)
- allowing None for record mode (jsherril@redhat.com)
- fixes for pull request (jsherril@redhat.com)
- Update to support proper get params with multiple values
  (jsherril@redhat.com)
- pulp v2 - consumer - initial changes for
  create/review/update/delete/profile/profile upload (bbuckingham@redhat.com)
- moving importers and distributors to their own files (jsherril@redhat.com)
- adding schedule extension and moviing requires (jsherril@redhat.com)
- adding new vcr data (jsherril@redhat.com)
- adding tests for repoistory schedules (jsherril@redhat.com)
- moving unit repo listing to runcible (jsherril@redhat.com)
- some task changes, properly implementing sync_status (jsherril@redhat.com)
- updated vcr data (jsherril@redhat.com)
- moving all unit_copy items to runcible (jsherril@redhat.com)
- new vcr data (jsherril@redhat.com)
- adding importer/distributor extensions and tests (jsherril@redhat.com)
- README update for tests (jsherril@redhat.com)
- adding importer and exporter objects (jsherril@redhat.com)
- Updates to re-scope from Pulp to Resources and from Pulp to Extensions and
  fit in line more with the directory structure. (ehelms@redhat.com)
- Version bump. (ehelms@redhat.com)

* Tue Oct 09 2012 Eric D. Helms <ehelms@redhat.com>
- Version bump to 0.1 (ehelms@redhat.com)
- Removing puts in helper that are not quite helpful. (ehelms@redhat.com)
- Adds i18n for activesupport. (ehelms@redhat.com)
- Typo in Gemfile. (ehelms@redhat.com)
- Adds missing active_support requirement. (ehelms@redhat.com)
- Updates to testing to allow recorded and none modes to be run on a system
  without pulp installed.  Adds option to turn logging during testing off or
  on. (ehelms@redhat.com)
- Removes references to ruby-debug. (ehelms@redhat.com)
- Adds rake to Gemfile. (ehelms@redhat.com)
- Removes ruby-debug from Gemfile, adds none as the default test mode and adds
  a basic travis config file. (ehelms@redhat.com)
- merge conflicts (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- uncommenting some repo test code (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- fixing broken test (jsherril@redhat.com)
- cleaning up search tests (jsherril@redhat.com)
- pulpv2 - consumer - adding apis for repo binding and content actions
  (bbuckingham@redhat.com)
- moving repository test (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- adding distributions and other unit tests (jsherril@redhat.com)
- adding new ignore (jsherril@redhat.com)
- pulpv2 - adding retrieve all for users and re-organizing
  (jsherril@redhat.com)
- Merge pull request #5 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- adding testing for rpm/errata/category/group (jsherril@redhat.com)
- Revert "removing generate_metadata as it is not a valid option"
  (jsherril@redhat.com)
- adding units (jsherril@redhat.com)
- removing spaces (jsherril@redhat.com)
- removing generate_metadata as it is not a valid option (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- Merge pull request #4 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- pull request comment (jsherril@redhat.com)
- addressing pull request comments (jsherril@redhat.com)
- fixing return on publish_all extension (jsherril@redhat.com)
- new cassettes (jsherril@redhat.com)
- adding event notifiers to runcible (jsherril@redhat.com)
- cassette update (jsherril@redhat.com)
- adding extension test (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- moving some tests to their own vcr cassettes for isolation, also
  consolidating setups into before_suites (jsherril@redhat.com)
- reducing sleep time (jsherril@redhat.com)
- really adding None record type (jsherril@redhat.com)
- Small fix to get pulp repo test running (paji@redhat.com)
- addressing previous commits comments (jsherril@redhat.com)
- fixes #2 - fixing typo in gemspec (jsherril@redhat.com)
- Adding missing license (jsherril@redhat.com)
- updating readme to point to none mode (jsherril@redhat.com)
- updating vcr cassettes (jsherril@redhat.com)
- Moving with_indifferent_access to base (jsherril@redhat.com)
- removing unintentionally commented out section (jsherril@redhat.com)
- adding unit unassociation methods (jsherril@redhat.com)
- allowing None for record mode (jsherril@redhat.com)
- fixes for pull request (jsherril@redhat.com)
- Update to support proper get params with multiple values
  (jsherril@redhat.com)
- pulp v2 - consumer - initial changes for
  create/review/update/delete/profile/profile upload (bbuckingham@redhat.com)
- moving importers and distributors to their own files (jsherril@redhat.com)
- adding schedule extension and moviing requires (jsherril@redhat.com)
- adding new vcr data (jsherril@redhat.com)
- adding tests for repoistory schedules (jsherril@redhat.com)
- moving unit repo listing to runcible (jsherril@redhat.com)
- some task changes, properly implementing sync_status (jsherril@redhat.com)
- updated vcr data (jsherril@redhat.com)
- moving all unit_copy items to runcible (jsherril@redhat.com)
- new vcr data (jsherril@redhat.com)
- adding importer/distributor extensions and tests (jsherril@redhat.com)
- README update for tests (jsherril@redhat.com)
- adding importer and exporter objects (jsherril@redhat.com)
- Updates to re-scope from Pulp to Resources and from Pulp to Extensions and
  fit in line more with the directory structure. (ehelms@redhat.com)
- Version bump. (ehelms@redhat.com)

* Tue Oct 09 2012 Eric D. Helms <ehelms@redhat.com> 0.1.0-1
- Removing puts in helper that are not quite helpful. (ehelms@redhat.com)
- Adds i18n for activesupport. (ehelms@redhat.com)
- Typo in Gemfile. (ehelms@redhat.com)
- Adds missing active_support requirement. (ehelms@redhat.com)
- Updates to testing to allow recorded and none modes to be run on a system
  without pulp installed.  Adds option to turn logging during testing off or
  on. (ehelms@redhat.com)
- Removes references to ruby-debug. (ehelms@redhat.com)
- Adds rake to Gemfile. (ehelms@redhat.com)
- Removes ruby-debug from Gemfile, adds none as the default test mode and adds
  a basic travis config file. (ehelms@redhat.com)
- merge conflicts (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- uncommenting some repo test code (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- fixing broken test (jsherril@redhat.com)
- cleaning up search tests (jsherril@redhat.com)
- pulpv2 - consumer - adding apis for repo binding and content actions
  (bbuckingham@redhat.com)
- moving repository test (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- adding distributions and other unit tests (jsherril@redhat.com)
- adding new ignore (jsherril@redhat.com)
- pulpv2 - adding retrieve all for users and re-organizing
  (jsherril@redhat.com)
- Merge pull request #5 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- adding testing for rpm/errata/category/group (jsherril@redhat.com)
- Revert "removing generate_metadata as it is not a valid option"
  (jsherril@redhat.com)
- adding units (jsherril@redhat.com)
- removing spaces (jsherril@redhat.com)
- removing generate_metadata as it is not a valid option (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- Merge pull request #4 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- pull request comment (jsherril@redhat.com)
- addressing pull request comments (jsherril@redhat.com)
- fixing return on publish_all extension (jsherril@redhat.com)
- new cassettes (jsherril@redhat.com)
- adding event notifiers to runcible (jsherril@redhat.com)
- cassette update (jsherril@redhat.com)
- adding extension test (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- moving some tests to their own vcr cassettes for isolation, also
  consolidating setups into before_suites (jsherril@redhat.com)
- reducing sleep time (jsherril@redhat.com)
- really adding None record type (jsherril@redhat.com)
- Small fix to get pulp repo test running (paji@redhat.com)
- addressing previous commits comments (jsherril@redhat.com)
- fixes #2 - fixing typo in gemspec (jsherril@redhat.com)
- Adding missing license (jsherril@redhat.com)
- updating readme to point to none mode (jsherril@redhat.com)
- updating vcr cassettes (jsherril@redhat.com)
- Moving with_indifferent_access to base (jsherril@redhat.com)
- removing unintentionally commented out section (jsherril@redhat.com)
- adding unit unassociation methods (jsherril@redhat.com)
- allowing None for record mode (jsherril@redhat.com)
- fixes for pull request (jsherril@redhat.com)
- Update to support proper get params with multiple values
  (jsherril@redhat.com)
- pulp v2 - consumer - initial changes for
  create/review/update/delete/profile/profile upload (bbuckingham@redhat.com)
- moving importers and distributors to their own files (jsherril@redhat.com)
- adding schedule extension and moviing requires (jsherril@redhat.com)
- adding new vcr data (jsherril@redhat.com)
- adding tests for repoistory schedules (jsherril@redhat.com)
- moving unit repo listing to runcible (jsherril@redhat.com)
- some task changes, properly implementing sync_status (jsherril@redhat.com)
- updated vcr data (jsherril@redhat.com)
- moving all unit_copy items to runcible (jsherril@redhat.com)
- new vcr data (jsherril@redhat.com)
- adding importer/distributor extensions and tests (jsherril@redhat.com)
- README update for tests (jsherril@redhat.com)
- adding importer and exporter objects (jsherril@redhat.com)
- Updates to re-scope from Pulp to Resources and from Pulp to Extensions and
  fit in line more with the directory structure. (ehelms@redhat.com)
- Version bump. (ehelms@redhat.com)

* Tue Oct 09 2012 Eric D. Helms <ehelms@redhat.com> 0.1.1-1
- Removing puts in helper that are not quite helpful. (ehelms@redhat.com)
- Adds i18n for activesupport. (ehelms@redhat.com)
- Typo in Gemfile. (ehelms@redhat.com)
- Adds missing active_support requirement. (ehelms@redhat.com)
- Updates to testing to allow recorded and none modes to be run on a system
  without pulp installed.  Adds option to turn logging during testing off or
  on. (ehelms@redhat.com)
- Removes references to ruby-debug. (ehelms@redhat.com)
- Adds rake to Gemfile. (ehelms@redhat.com)
- Removes ruby-debug from Gemfile, adds none as the default test mode and adds
  a basic travis config file. (ehelms@redhat.com)
- merge conflicts (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- uncommenting some repo test code (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- fixing broken test (jsherril@redhat.com)
- cleaning up search tests (jsherril@redhat.com)
- pulpv2 - consumer - adding apis for repo binding and content actions
  (bbuckingham@redhat.com)
- moving repository test (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- adding distributions and other unit tests (jsherril@redhat.com)
- adding new ignore (jsherril@redhat.com)
- pulpv2 - adding retrieve all for users and re-organizing
  (jsherril@redhat.com)
- Merge pull request #5 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- adding testing for rpm/errata/category/group (jsherril@redhat.com)
- Revert "removing generate_metadata as it is not a valid option"
  (jsherril@redhat.com)
- adding units (jsherril@redhat.com)
- removing spaces (jsherril@redhat.com)
- removing generate_metadata as it is not a valid option (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- Merge pull request #4 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- pull request comment (jsherril@redhat.com)
- addressing pull request comments (jsherril@redhat.com)
- fixing return on publish_all extension (jsherril@redhat.com)
- new cassettes (jsherril@redhat.com)
- adding event notifiers to runcible (jsherril@redhat.com)
- cassette update (jsherril@redhat.com)
- adding extension test (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- moving some tests to their own vcr cassettes for isolation, also
  consolidating setups into before_suites (jsherril@redhat.com)
- reducing sleep time (jsherril@redhat.com)
- really adding None record type (jsherril@redhat.com)
- Small fix to get pulp repo test running (paji@redhat.com)
- addressing previous commits comments (jsherril@redhat.com)
- fixes #2 - fixing typo in gemspec (jsherril@redhat.com)
- Adding missing license (jsherril@redhat.com)
- updating readme to point to none mode (jsherril@redhat.com)
- updating vcr cassettes (jsherril@redhat.com)
- Moving with_indifferent_access to base (jsherril@redhat.com)
- removing unintentionally commented out section (jsherril@redhat.com)
- adding unit unassociation methods (jsherril@redhat.com)
- allowing None for record mode (jsherril@redhat.com)
- fixes for pull request (jsherril@redhat.com)
- Update to support proper get params with multiple values
  (jsherril@redhat.com)
- pulp v2 - consumer - initial changes for
  create/review/update/delete/profile/profile upload (bbuckingham@redhat.com)
- moving importers and distributors to their own files (jsherril@redhat.com)
- adding schedule extension and moviing requires (jsherril@redhat.com)
- adding new vcr data (jsherril@redhat.com)
- adding tests for repoistory schedules (jsherril@redhat.com)
- moving unit repo listing to runcible (jsherril@redhat.com)
- some task changes, properly implementing sync_status (jsherril@redhat.com)
- updated vcr data (jsherril@redhat.com)
- moving all unit_copy items to runcible (jsherril@redhat.com)
- new vcr data (jsherril@redhat.com)
- adding importer/distributor extensions and tests (jsherril@redhat.com)
- README update for tests (jsherril@redhat.com)
- adding importer and exporter objects (jsherril@redhat.com)
- Updates to re-scope from Pulp to Resources and from Pulp to Extensions and
  fit in line more with the directory structure. (ehelms@redhat.com)
- Version bump. (ehelms@redhat.com)

* Tue Oct 09 2012 Eric D. Helms <ehelms@redhat.com>
- Removing puts in helper that are not quite helpful. (ehelms@redhat.com)
- Adds i18n for activesupport. (ehelms@redhat.com)
- Typo in Gemfile. (ehelms@redhat.com)
- Adds missing active_support requirement. (ehelms@redhat.com)
- Updates to testing to allow recorded and none modes to be run on a system
  without pulp installed.  Adds option to turn logging during testing off or
  on. (ehelms@redhat.com)
- Removes references to ruby-debug. (ehelms@redhat.com)
- Adds rake to Gemfile. (ehelms@redhat.com)
- Removes ruby-debug from Gemfile, adds none as the default test mode and adds
  a basic travis config file. (ehelms@redhat.com)
- merge conflicts (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- uncommenting some repo test code (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- fixing broken test (jsherril@redhat.com)
- cleaning up search tests (jsherril@redhat.com)
- pulpv2 - consumer - adding apis for repo binding and content actions
  (bbuckingham@redhat.com)
- moving repository test (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- adding distributions and other unit tests (jsherril@redhat.com)
- adding new ignore (jsherril@redhat.com)
- pulpv2 - adding retrieve all for users and re-organizing
  (jsherril@redhat.com)
- Merge pull request #5 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- adding testing for rpm/errata/category/group (jsherril@redhat.com)
- Revert "removing generate_metadata as it is not a valid option"
  (jsherril@redhat.com)
- adding units (jsherril@redhat.com)
- removing spaces (jsherril@redhat.com)
- removing generate_metadata as it is not a valid option (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- Merge pull request #4 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- pull request comment (jsherril@redhat.com)
- addressing pull request comments (jsherril@redhat.com)
- fixing return on publish_all extension (jsherril@redhat.com)
- new cassettes (jsherril@redhat.com)
- adding event notifiers to runcible (jsherril@redhat.com)
- cassette update (jsherril@redhat.com)
- adding extension test (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- moving some tests to their own vcr cassettes for isolation, also
  consolidating setups into before_suites (jsherril@redhat.com)
- reducing sleep time (jsherril@redhat.com)
- really adding None record type (jsherril@redhat.com)
- Small fix to get pulp repo test running (paji@redhat.com)
- addressing previous commits comments (jsherril@redhat.com)
- fixes #2 - fixing typo in gemspec (jsherril@redhat.com)
- Adding missing license (jsherril@redhat.com)
- updating readme to point to none mode (jsherril@redhat.com)
- updating vcr cassettes (jsherril@redhat.com)
- Moving with_indifferent_access to base (jsherril@redhat.com)
- removing unintentionally commented out section (jsherril@redhat.com)
- adding unit unassociation methods (jsherril@redhat.com)
- allowing None for record mode (jsherril@redhat.com)
- fixes for pull request (jsherril@redhat.com)
- Update to support proper get params with multiple values
  (jsherril@redhat.com)
- pulp v2 - consumer - initial changes for
  create/review/update/delete/profile/profile upload (bbuckingham@redhat.com)
- moving importers and distributors to their own files (jsherril@redhat.com)
- adding schedule extension and moviing requires (jsherril@redhat.com)
- adding new vcr data (jsherril@redhat.com)
- adding tests for repoistory schedules (jsherril@redhat.com)
- moving unit repo listing to runcible (jsherril@redhat.com)
- some task changes, properly implementing sync_status (jsherril@redhat.com)
- updated vcr data (jsherril@redhat.com)
- moving all unit_copy items to runcible (jsherril@redhat.com)
- new vcr data (jsherril@redhat.com)
- adding importer/distributor extensions and tests (jsherril@redhat.com)
- README update for tests (jsherril@redhat.com)
- adding importer and exporter objects (jsherril@redhat.com)
- Updates to re-scope from Pulp to Resources and from Pulp to Extensions and
  fit in line more with the directory structure. (ehelms@redhat.com)
- Version bump. (ehelms@redhat.com)

* Tue Oct 09 2012 Eric D. Helms <ehelms@redhat.com> 0.1.1-1
- Removing puts in helper that are not quite helpful. (ehelms@redhat.com)
- Adds i18n for activesupport. (ehelms@redhat.com)
- Typo in Gemfile. (ehelms@redhat.com)
- Adds missing active_support requirement. (ehelms@redhat.com)
- Updates to testing to allow recorded and none modes to be run on a system
  without pulp installed.  Adds option to turn logging during testing off or
  on. (ehelms@redhat.com)
- Removes references to ruby-debug. (ehelms@redhat.com)
- Adds rake to Gemfile. (ehelms@redhat.com)
- Removes ruby-debug from Gemfile, adds none as the default test mode and adds
  a basic travis config file. (ehelms@redhat.com)
- merge conflicts (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- uncommenting some repo test code (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- fixing broken test (jsherril@redhat.com)
- cleaning up search tests (jsherril@redhat.com)
- pulpv2 - consumer - adding apis for repo binding and content actions
  (bbuckingham@redhat.com)
- moving repository test (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- adding distributions and other unit tests (jsherril@redhat.com)
- adding new ignore (jsherril@redhat.com)
- pulpv2 - adding retrieve all for users and re-organizing
  (jsherril@redhat.com)
- Merge pull request #5 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- adding testing for rpm/errata/category/group (jsherril@redhat.com)
- Revert "removing generate_metadata as it is not a valid option"
  (jsherril@redhat.com)
- adding units (jsherril@redhat.com)
- removing spaces (jsherril@redhat.com)
- removing generate_metadata as it is not a valid option (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- Merge pull request #4 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- cassette updates (jsherril@redhat.com)
- pull request comment (jsherril@redhat.com)
- addressing pull request comments (jsherril@redhat.com)
- fixing return on publish_all extension (jsherril@redhat.com)
- new cassettes (jsherril@redhat.com)
- adding event notifiers to runcible (jsherril@redhat.com)
- cassette update (jsherril@redhat.com)
- adding extension test (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream-runcible/master' into fork-runcible-
  pulpv2 (bbuckingham@redhat.com)
- cassette updates (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- moving some tests to their own vcr cassettes for isolation, also
  consolidating setups into before_suites (jsherril@redhat.com)
- reducing sleep time (jsherril@redhat.com)
- really adding None record type (jsherril@redhat.com)
- Small fix to get pulp repo test running (paji@redhat.com)
- addressing previous commits comments (jsherril@redhat.com)
- fixes #2 - fixing typo in gemspec (jsherril@redhat.com)
- Adding missing license (jsherril@redhat.com)
- updating readme to point to none mode (jsherril@redhat.com)
- updating vcr cassettes (jsherril@redhat.com)
- Moving with_indifferent_access to base (jsherril@redhat.com)
- removing unintentionally commented out section (jsherril@redhat.com)
- adding unit unassociation methods (jsherril@redhat.com)
- allowing None for record mode (jsherril@redhat.com)
- fixes for pull request (jsherril@redhat.com)
- Update to support proper get params with multiple values
  (jsherril@redhat.com)
- pulp v2 - consumer - initial changes for
  create/review/update/delete/profile/profile upload (bbuckingham@redhat.com)
- moving importers and distributors to their own files (jsherril@redhat.com)
- adding schedule extension and moviing requires (jsherril@redhat.com)
- adding new vcr data (jsherril@redhat.com)
- adding tests for repoistory schedules (jsherril@redhat.com)
- moving unit repo listing to runcible (jsherril@redhat.com)
- some task changes, properly implementing sync_status (jsherril@redhat.com)
- updated vcr data (jsherril@redhat.com)
- moving all unit_copy items to runcible (jsherril@redhat.com)
- new vcr data (jsherril@redhat.com)
- adding importer/distributor extensions and tests (jsherril@redhat.com)
- README update for tests (jsherril@redhat.com)
- adding importer and exporter objects (jsherril@redhat.com)
- Updates to re-scope from Pulp to Resources and from Pulp to Extensions and
  fit in line more with the directory structure. (ehelms@redhat.com)
- Version bump. (ehelms@redhat.com)

* Fri Sep 14 2012 Eric D. Helms <ehelms@redhat.com> 0.0.9-1
- Updates verison. (ehelms@redhat.com)
- Minor updates to spec file. (ehelms@redhat.com)
- Automatic commit of package [rubygem-runcible] release [0.0.7-1].
  (ehelms@redhat.com)

* Fri Sep 14 2012 Eric D. Helms <ehelms@redhat.com>
- Automatic commit of package [rubygem-runcible] release [0.0.8-1].
  (ehelms@redhat.com)

* Fri Sep 14 2012 Eric D. Helms <ehelms@redhat.com> 0.0.8-1
- Minor updates to spec file. (ehelms@redhat.com)
- Automatic commit of package [rubygem-runcible] release [0.0.7-1].
  (ehelms@redhat.com)

* Fri Sep 14 2012 Eric D. Helms <ehelms@redhat.com>
- Minor updates to spec file. (ehelms@redhat.com)
- Automatic commit of package [rubygem-runcible] release [0.0.7-1].
  (ehelms@redhat.com)

* Fri Sep 14 2012 Eric D. Helms <ehelms@redhat.com>
- Minor updates to spec file. (ehelms@redhat.com)
- Automatic commit of package [rubygem-runcible] release [0.0.7-1].
  (ehelms@redhat.com)

* Fri Sep 14 2012 Eric D. Helms <ehelms@redhat.com> 0.0.7-1
- Updates to spec file. (ehelms@redhat.com)
- Moves install directive into prep section. (ehelms@redhat.com)
- Flipping order of prep steps. (ehelms@redhat.com)
- Fixing typo in source declaration in spec file. (ehelms@redhat.com)
- Updates to spec file variables. (ehelms@redhat.com)
- Adds documentation subpackage and cleans up spec file to handle tar.gz
  source. (ehelms@redhat.com)

* Fri Sep 14 2012 Eric D. Helms <ehelms@redhat.com> 0.0.6-1
- new package built with tito
