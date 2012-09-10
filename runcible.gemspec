# -*- encoding: utf-8 -*-
require File.expand_path('../lib/runcible/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eric D Helms"]
  gem.email         = ["ehelms@redhat.com"]
  gem.description   = "Exposing pulp's juiciest components to the Ruby world."
  gem.summary       = ""
  gem.homepage      = "https://github.com/Katello/runcible"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "runcible"
  gem.require_paths = ["lib"]
  gem.version       = Runcible::VERSION
end
