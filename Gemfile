source 'https://rubygems.org'

# Specify your gem's dependencies in runcible.gemspec
gemspec

group :test do
  gem 'rake', '0.9.2.2'
  gem 'vcr'
  gem 'webmock'
  gem 'minitest', '~> 4.7'
  gem 'parseconfig'
  gem 'mocha', "~> 0.14.0"
  gem 'rubocop', "0.24.1"
end

group :debug do
  gem 'debugger' if RUBY_VERSION == "1.9.3"
end
