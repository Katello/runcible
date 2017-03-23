# Runcible

[![Build Status](https://secure.travis-ci.org/Katello/runcible.png)](http://travis-ci.org/Katello/runcible)
[![Coverage Status](https://coveralls.io/repos/github/Katello/runcible/badge.svg?branch=master)](https://coveralls.io/github/Katello/runcible?branch=master)

Exposing Pulp's juiciest parts. http://www.pulpproject.org/

Latest Live Tested Version: **pulp-server-2.12.1-1.el7.noarch**

Current stable Runcible: https://github.com/Katello/runcible/tree/0.3

For in-depth class and method documentation: http://katello.github.com/runcible/

Please file new issues here: [Redmine](http://projects.theforeman.org/projects/runcible/issues/new)

## Installation

Add this line to your application's Gemfile:

    gem 'runcible'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install runcible

## Usage

### Set Configuration

To use a single resource or extension, the configuration can be set:

    repo_api = Runcible::Resources::Repository.new({
                :url      => "",
                :api_path => "",
                :user     => "",
                :logger   => ""
              })
    repo_api.find(id)

Alternatively, a single 'server' instance which can easily use all 
  resources and extensions can be instantiated:

    my_runcible = Runcible::Instance.new({
                :url      => "",
                :api_path => "",
                :user     => "",
                :logger   => ""
              })
     my_runcible.resources.repository.find(id)

Required Configuration:

    :uri      => The base URI of the Pulp server (default: https://localhost)
    :api_path => The API path of the Pulp server (default: pulp/api/v2/)
    :user     => The Pulp username to be used in authentication
    :logger   => The location to log RestClient calls (e.g. stdout)
  
Authentication Options are either HTTP or Oauth:

    :http_auth  => {:password => ''}

    :oauth      => {:oauth_secret => "",
                    :oauth_key    => "" }

For an example on parsing the Pulp server.conf and using values provided within for the configuration see the [test_runner](https://github.com/Katello/runcible/blob/master/test/integration/test_runner.rb)

### Make a Request

Runcible provides two representations of Pulp entities to make API calls: [resources](https://github.com/Katello/runcible/tree/master/lib/runcible/resources) and [extensions](https://github.com/Katello/runcible/tree/master/lib/runcible/extensions)

The best examples of how to use either the resources or extensions can be found within the [tests](https://github.com/Katello/runcible/tree/master/test/integration)

#### Resources

Resources are designed to be one-for-one with the Pulp API calls in terms of required parameters and naming of the calls.  For example, in order to create a repository, associate a Yum importer and a distributor:

    my_runcible = Runcible::Instance.new(config)
    my_runcible.resources.repository.create("Repository_ID")
    my_runcible.resources.repository.associate_importer("Repository_ID", "yum_importer", {})
    my_runcible.resources.repository.associate_distributor("Repository_ID", "yum_distributor", {"relative_url" => "/", "http" => true, "https" => true})

    or

    Runcible::Resources::Repository.new(config).create("Repository_ID")
    Runcible::Resources::Repository.new(config).associate_importer("Repository_ID", "yum_importer", {})
    Runcible::Resources::Repository.new(config).associate_distributor("Repository_ID", "yum_distributor", {"relative_url" => "/", "http" => true, "https" => true})

#### Extensions

Extensions are constructs around the Pulp API that make retrieving, accessing or creating certain data types easier.  For example, providing objects that represent the details of a yum importer or distributor, and providing functions to create a Repository with an importer and distributors in a single call.  The same three step process above using extensions is:

    my_runcible = Runcible::Instance.new(config)
    my_runcible.extensions.repository.create_with_importer_and_distributor("Repository_ID", {:id=>'yum_importer'}, [{'type_id' => 'yum_distributor', 'id'=>'123', 'auto_publish'=>true, 'config'=>{'relative_url' => '/', 'http' => true, 'https' => true}}])

    or

    Runcible::Extensions::Repository.new(config).create_with_importer_and_distributors("Repository_ID", {:id=>'yum_importer'}, [{'type_id' => 'yum_distributor', 'id'=>'123', 'auto_publish'=>true, 'config'=>{'relative_url' => '/', 'http' => true, 'https' => true}}])

Alternatively, using distributor and importer objects:

    distributors = [Runcible::Models::YumDistributor.new('/path', true, true, :id => '123')]
    importer = Runcible::Models::YumImporter.new()

    my_runcible = Runcible::Instance.new(config)
    my_runcible.extensions.repository.create_with_importer_and_distributors("Repository_ID", importer, distributors)

    or

    Runcible::Extensions::Repository.new(config).create_with_importer_and_distributors("Repository_ID", importer, distributors)

## Testing

### Dependencies

In order to run and develop the ostree code in runcible locally, you will need
to install the pulp ostree packages (namely pulp-python-plugins and
pulp-ostree-plugins).

If you don't have ostree intalled already, you'll need to setup the ostree repo
as ostree is a dependency for pulp-ostree-plugins. For centos, you'll create
/etc/yum.repos.d/ostree.repo with this:

```
[atomic7-testing]
name=atomic7-testing
baseurl=http://cbs.centos.org/repos/atomic7-testing/x86_64/os/
gpgcheck=0
enabled=1
```

Now you should be able to install the two pulp plugin packages:

```
sudo yum install pulp-python-plugins pulp-ostree-plugins
```

Finally, update your pulp database and restart pulp:

```
sudo -u apache pulp-manage-db
for x in httpd pulp_resource_manager pulp_celerybeat pulp_workers; do sudo service $x restart; done
```

### Running Tests

To run all tests using recorded data, run:

    rake test mode=none

To run all tests to record data:
   
    rake test mode=all

To run a single test using recorded data, run:
   
    rake test mode=none test=extensions/respository
    or (by filename)
    rake test mode=none test=./test/extensions/respository_test.rb

Note that when you record data, it's a good idea to delete any corresponding
vcr cassette files as recording data will sometimes only append to these files.

To run tests against your live Pulp without recording a new cassette set record flag to false (does not apply to mode=none):

    record=false

To run with  oauth, simply append the following to any commend:
   
    auth_type=oauth

To see RestClient logs while testing:
  
    logging=true

## Updating Documentation

The documentation is built with yard and hosted on Github via the gh-pages branch of the repository. To update the documentation on Github:

    yard doc
    git checkout gh-pages
    cp -rf doc/* ./
    git add ./
    git commit -a -m 'Updating docs to version X.X'
    git push <upstream> gh-pages
    
## Building and Releasing

An official release of Runcible should include the release of a gem on rubygems.org and an update to the documentation branch. At a minimum, the following two actions should be performed for each release:

1. [Build and Release Gem](#gem)
2. [Updating Documentation](#updating-documentation)

### Gem

While anyone can grab the source and build a new version of the gem, only those with Rubygems.org permissions on the project can release an official version.

To build a new version of Runcible, first bump the version depending on the type of release.

    cd runcible/
    vim lib/runcible/version.rb

Now update the version to the new version, and commit the changes.

    git commit -a -m 'Version bump'

Now build:
    
    gem build runcible.gemspec


#### Official Release
  
For an official release, again assuming you have the right permssions:

    gem push runcible-<version>.gem

### RPM Release

If you are wanting to generate a new RPM build, please make sure you have followed the steps above if the build is going to include new code.  All builds should first go in gem form to Rubygems.  You'll need to make sure tito is installed:

    yum install tito

Now tag, making sure the tag version matches the gem version:

    tito tag

Assuming you have the right dependencies available, you can do a local test build with tito (although we recommend using mock):

    tito build --test --rpm

With mock:

    tito build --test --rpm --builder=mock --builder-arg mock=<name_of_mock_config>

From here there are a variety of options to build and release an RPM pakaged version of Runcible (e.g. you can build an SRPM to feed to Koji, or use mock locally)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Ensure all tests are passing
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
