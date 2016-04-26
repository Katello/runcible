source 'https://rubygems.org'

# Specify your gem's dependencies in runcible.gemspec
gemspec

group :test do
  gem 'rake', '0.9.2.2'
  gem 'vcr'
  gem 'webmock', '< 2.0.0' # https://github.com/vcr/vcr/issues/570
  gem 'minitest', '~> 4.7'
  gem 'parseconfig'
  gem 'mocha', "~> 0.14.0"
end

group :debug do
  gem 'debugger'
end
