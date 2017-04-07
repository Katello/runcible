# -*- encoding: utf-8 -*-
require File.expand_path('../lib/runcible/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Eric D Helms, Justin Sherrill']
  gem.email         = ['ehelms@redhat.com, jsherril@redhat.com']
  gem.description   = "Exposing Pulp's juiciest components to the Ruby world."
  gem.summary       = ''
  gem.homepage      = 'https://github.com/Katello/runcible'

  gem.files         = Dir['lib/**/*.rb'] + ['LICENSE', 'Rakefile', 'Gemfile',
                                            'README.md', 'CONTRIBUTING.md']
  gem.test_files    = gem.files.grep(/^(test)/)
  gem.name          = 'runcible'
  gem.require_paths = ['lib']
  gem.version       = Runcible::VERSION

  gem.add_dependency('json')
  gem.add_dependency('rest-client', ['>= 1.6.1', '< 3.0.0'])
  gem.add_dependency('oauth')
  gem.add_dependency('activesupport', '>= 3.0.10')
  gem.add_dependency('i18n', '>= 0.5.0')

  gem.add_development_dependency('yard')
  gem.add_development_dependency('maruku')
end
