# Runcible

[![Build Status](https://secure.travis-ci.org/Katello/runcible.png)](http://travis-ci.org/Katello/runcible)

Exposing Pulp's juiciest parts. http://www.pulpproject.org/

## Installation

Add this line to your application's Gemfile:

    gem 'runcible'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install runcible

## Usage

TODO: Write usage instructions here

## Testing

To run all tests using recorded data, run:
   rake test:integration mode=none

To run all tests to record data:
   rake test:integration mode=live

To run a single test using recorded data, run:
   rake test:integration mode=none test=/path/to/test.rb

To run with  oauth, simply append the following to any commend:
   auth_type=oauth

To see RestClient logs while testing:
  logging=true

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
