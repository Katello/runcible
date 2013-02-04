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
Version:        0.3.2
Release:        1%{?dist}
URL:            https://github.com/Katello/runcible
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{gem_name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       ruby(abi) = %{rubyabi}
Requires:       ruby(rubygems) 
Requires:       rubygem(json) 
Requires:       rubygem(rest-client) >= 1.6.1
Requires:       rubygem(oauth) 
Requires:       rubygem(activesupport) >= 3.0.10
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
%dir %{gem_instdir}
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
* Mon Feb 04 2013 Justin Sherrill <jsherril@redhat.com> 0.3.2-1
- Logging - Test update. (ehelms@redhat.com)
- Logging - Updates to prevent logging twice in the event an exception is
  thrown when the log level is at debug. (ehelms@redhat.com)
- Gemspec cleanup by moving dependencies into the gemspec file.
  (ehelms@redhat.com)
- Updates logging code to allow logging of all requests (debug mode) and a
  special exceptions mode for only logging to a provided logger calls that
  generate exceptions. (ehelms@redhat.com)
- Updates readme to include new test option. (ehelms@redhat.com)
- Moves primary tests into top level test directory and re-factors the test
  commands to account for the changes. Resources and extension suites may now
  be run separately now. (ehelms@redhat.com)
- Adds environment variable to allow running full test suite against a live
  Pulp without recording new cassettes. (ehelms@redhat.com)
- Updates README to include a section on building and releasin gem or RPM.
  (ehelms@redhat.com)
- being less restrictive on activesupport version in Gemfile
  (jsherril@redhat.com)
- being less restrictive on activesupport version (jsherril@redhat.com)
- Renamed test methods to quiten travis (paji@redhat.com)
- Redid the tests to make em more explicit (paji@redhat.com)
- Fixed a test (paji@redhat.com)
- Accidental blooper where I missed a method name (paji@redhat.com)
- Added some cosmetic changes for clarity (paji@redhat.com)
- Updated unit tests to make travis happy (paji@redhat.com)
- Removed accidental space (paji@redhat.com)
- Updated content unassociate calls to be based of unit_id or content_id
  (paji@redhat.com)
- Moved the copy and unassociate logic to a more centralized location
  (paji@redhat.com)

* Wed Jan 16 2013 Justin Sherrill <jsherril@redhat.com> 0.3.1-1
- version bump to 0.3.1 (jsherril@redhat.com)
- fixes #35 - correctly default to include repos info in unit finds
  (jsherril@redhat.com)

* Fri Jan 11 2013 Eric D Helms <ehelms@redhat.com> 0.3.0-1
- Version bump. (ehelms@redhat.com)
- Adds tests for content_type. (ehelms@redhat.com)
- Updates to how the content type is declared for extensions. Test updates.
  (ehelms@redhat.com)
- Series of documentation updates for extensions that include the addition of a
  base Unit extension that all content types inherit from. (ehelms@redhat.com)
- Updating to first Pulp V2.0 stable build. (ehelms@redhat.com)
- minor version bump (jsherril@redhat.com)
- cassette update (jsherril@redhat.com)
- fixing package category test
- adding package group copy (jsherril@redhat.com)
- Automatic commit of package [rubygem-runcible] release [0.2.0-1].
  (ehelms@redhat.com)
- Spec file updates to remove redundant directory declarations.
  (ehelms@redhat.com)

* Mon Nov 19 2012 Eric D Helms <ehelms@redhat.com> 0.2.0-1
- Spec file updates to remove redundant directory declarations.
  (ehelms@redhat.com)
- Version bump. (ehelms@redhat.com)
- cassette updates (jsherril@redhat.com)
- sleep longer for fewer waiting tasks (jsherril@redhat.com)
- fixing errata copy by unit id (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- fixing typo in rakefile (jsherril@redhat.com)
- adding errata test (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- do not sleep if were running as none (jsherril@redhat.com)
- switching to primarily use unit ids for errata (jsherril@redhat.com)
- Assert - Cleans up copy/paste fail on a test name and associated tests.
  (ehelms@redhat.com)
- Asserts - Cleans up the asserts in extensions. (ehelms@redhat.com)
- Asserts - Cleans up the asserts to use more minitest asserts in resources to
  provide more friendly output. (ehelms@redhat.com)
- Updates readme with link to github pages. (ehelms@redhat.com)
- Doc - Adds references to the latest Pulp doc location for each entity.
  (ehelms@redhat.com)
- Fixes broken reference. (ehelms@redhat.com)
- DOC - Adds documentation for all resources. (ehelms@redhat.com)
- Fixes for none mode test runs. (ehelms@redhat.com)
- Pulp Beta - Updates to handle Repository deletion and consumer unbind as
  tasks to remove chance for race condition. (ehelms@redhat.com)
- Pulp Beta - Adds missing cassettes and updates test data. (ehelms@redhat.com)
- Updates to the latest pulp beta and fixes all associated tests.
  (ehelms@redhat.com)
- Docs - Adds yard doc for repository. (ehelms@redhat.com)
- Updates to fix missing cassette and switches each content type to extend Unit
  resource. (ehelms@redhat.com)
- Version bump. (ehelms@redhat.com)
- Merge branch 'master' of github.com:Katello/runcible (ehelms@redhat.com)
- Updates test data to reflect added tests. (ehelms@redhat.com)
- Adds and cleans-up functions that having missing or mis-named tests.
  (ehelms@redhat.com)
- Updates Travis to fail if there are untested functions. (ehelms@redhat.com)
- Adds rake task to find functions without corresponding test functions.
  (ehelms@redhat.com)
- cassette update (jsherril@redhat.com)
- do not use sorting for unit search, as mongo may fail (jsherril@redhat.com)
- Updating pulp version (paji@redhat.com)

* Mon Nov 19 2012 Eric D Helms <ehelms@redhat.com> 0.2.0-1
- Version bump. (ehelms@redhat.com)
- cassette updates (jsherril@redhat.com)
- sleep longer for fewer waiting tasks (jsherril@redhat.com)
- fixing errata copy by unit id (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- fixing typo in rakefile (jsherril@redhat.com)
- adding errata test (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- do not sleep if were running as none (jsherril@redhat.com)
- switching to primarily use unit ids for errata (jsherril@redhat.com)
- Assert - Cleans up copy/paste fail on a test name and associated tests.
  (ehelms@redhat.com)
- Asserts - Cleans up the asserts in extensions. (ehelms@redhat.com)
- Asserts - Cleans up the asserts to use more minitest asserts in resources to
  provide more friendly output. (ehelms@redhat.com)
- Updates readme with link to github pages. (ehelms@redhat.com)
- Doc - Adds references to the latest Pulp doc location for each entity.
  (ehelms@redhat.com)
- Fixes broken reference. (ehelms@redhat.com)
- DOC - Adds documentation for all resources. (ehelms@redhat.com)
- Fixes for none mode test runs. (ehelms@redhat.com)
- Pulp Beta - Updates to handle Repository deletion and consumer unbind as
  tasks to remove chance for race condition. (ehelms@redhat.com)
- Pulp Beta - Adds missing cassettes and updates test data. (ehelms@redhat.com)
- Updates to the latest pulp beta and fixes all associated tests.
  (ehelms@redhat.com)
- Docs - Adds yard doc for repository. (ehelms@redhat.com)
- Updates to fix missing cassette and switches each content type to extend Unit
  resource. (ehelms@redhat.com)
- Version bump. (ehelms@redhat.com)
- Merge branch 'master' of github.com:Katello/runcible (ehelms@redhat.com)
- Updates test data to reflect added tests. (ehelms@redhat.com)
- Adds and cleans-up functions that having missing or mis-named tests.
  (ehelms@redhat.com)
- Updates Travis to fail if there are untested functions. (ehelms@redhat.com)
- Adds rake task to find functions without corresponding test functions.
  (ehelms@redhat.com)
- cassette update (jsherril@redhat.com)
- do not use sorting for unit search, as mongo may fail (jsherril@redhat.com)
- Updating pulp version (paji@redhat.com)

* Fri Nov 02 2012 Eric D. Helms <ehelms@redhat.com> 0.1.3-1
- Version bump. (ehelms@redhat.com)
- Cassette updates for tests. (ehelms@redhat.com)
- Fixes broken publish_all call and adds tests for publish and publish_all.
  (ehelms@redhat.com)
- Adding files to make travis happy in theory (paji@redhat.com)
- Changed the 'options' parameter to be  empty hash instead of a string since
  pulp expects that (paji@redhat.com)
- Changed the check for 'logging' suite name as suggested (paji@redhat.com)
- Replaced all the GPL licenses with MIT as requested by eric (paji@redhat.com)
- Fixed merge conflicts and regenerated yml cassettes (paji@redhat.com)
- Updated the required yml to make the runcible tests run (paji@redhat.com)
- Fixed a few consumer group tests (paji@redhat.com)
- Travis - Adds testing against 1.9.3 (ehelms@redhat.com)
- Merge branch 'master' of github.com:Katello/runcible (ehelms@redhat.com)
- Ruby 1.9.3 - Updates to get code and tests passing on both Ruby 1.8.7 and
  Ruby 1.9.3 (ehelms@redhat.com)
- Added calls in extensions to simplify adding and removing consumers from
  consumer groups (paji@redhat.com)
- Added consumer group associate and unassociate calls (paji@redhat.com)
- cassette update (jsherril@redhat.com)
- adding support for repository ids as part of repository unit listing
  (jsherril@redhat.com)
- fixing issue with sync cancel not working properly (jsherril@redhat.com)

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
