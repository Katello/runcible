# Runcible

[![Build Status](https://secure.travis-ci.org/Katello/runcible.png)](http://travis-ci.org/Katello/runcible)

Exposing Pulp's juiciest parts. http://www.pulpproject.org/

Latest Live Tested Version: **pulp-server-2.1.0-0.26.beta.noarch**

Current stable Runcible: https://github.com/Katello/runcible/tree/0.3

For in-depth class and method documentation: http://katello.github.com/runcible/

## Installation

Add this line to your application's Gemfile:

    gem 'runcible'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install runcible

## Usage

### Set Configuration

The base configuration allows for the following to be set.

    Runcible::Base.config = { 
                :url      => "",
                :api_path => "",
                :user     => "",
                :logger   => ""
              }

Required Configuration

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

Runcible provides two represntation's of Pulp entities to make API calls: [resources](https://github.com/Katello/runcible/tree/master/lib/runcible/resources) and [extensions](https://github.com/Katello/runcible/tree/master/lib/runcible/extensions)

The best examples of how to use either the resources or extensions can be found within the [tests](https://github.com/Katello/runcible/tree/master/test/integration)

#### Resources

Resources are designed to be one-for-one with the Pulp API calls in terms of required parameters and naming of the calls.  For example, in order to create a repository, associate a Yum importer and a distributor:

    Runcible::Resources::Repository.create("Repository_ID")
    Runcible::Resources::Repository.associate_importer("Repository_ID", "yum_importer", {})
    Runcible::Resources::Repository.associate_distributor("Repository_ID", "yum_distributor", {"relative_url" => "/", "http" => true, "https" => true})

#### Extensions

Extensions are constructs around the Pulp API that make retrieving, accessing or creating certain data types easier.  For example, providing objects that represent the details of a yum importer or distributor, and providing functions to create a Repository with an importer and distributors in a single call.  The same three step process above using extensions is:

    Runcible::Extensions::Repository.create_with_importer_and_distributors("Repository_ID", {:id=>'yum_importer'}, [{'type_id' => 'yum_distributor', 'id'=>'123', 'auto_publish'=>true, 'config'=>{'relative_url' => '/', 'http' => true, 'https' => true}}])

Alternatively, using distributor and importer objects:

    distributors = [Runcible::Extensions::YumDistributor.new('/path', true, true, :id => '123')]
    importer = Runcible::Extensions::YumImporter.new()
    Runcible::Extensions::Repository.create_with_importer_and_distributors("Repository_ID", importer, distributors)


## Testing

To run all tests using recorded data, run:

    rake test mode=none

To run all tests to record data:
   
    rake test mode=live

To run a single test using recorded data, run:
   
    rake test mode=none test=extensions/respository
    or (by filename)
    rake test mode=none test=./test/extensions/respository_test.rb

To run tests against your live Pulp without recording a new cassette set record flag to false (does not apply to mode=none):

    record=false

To run with  oauth, simply append the following to any commend:
   
    auth_type=oauth

To see RestClient logs while testing:
  
    logging=true


## Building and Releasing

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
