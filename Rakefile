#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rake/testtask'

def clear_cassettes
  `rm -rf test/fixtures/vcr_cassettes/*.yml`
  `rm -rf test/fixtures/vcr_cassettes/extensions/*.yml`
  `rm -rf test/fixtures/vcr_cassettes/support/*.yml`
  print "Cassettes cleared\n"
end

namespace :test do
  desc 'Runs the unit tests'
  Rake::TestTask.new :unit do |t|
    t.pattern = 'test/unit/test_*.rb'
  end

  [:resources, :extensions, :unit, :models].each do |task_name|
    desc "Runs the #{task_name} tests"
    task task_name do
      options = {}

      options[:mode]      = ENV['mode'] || 'none'
      options[:test_name] = ENV['test']
      options[:auth_type] = ENV['auth_type']
      options[:logging]   = ENV['logging']

      if !['new_episodes', 'all', 'none', 'once'].include?(options[:mode])
        puts 'Invalid test mode'
      else
        require './test/test_runner'

        test_runner = PulpMiniTestRunner.new

        if options[:test_name]
          puts "Running tests for: #{options[:test_name]}"
        else
          puts "Running tests for: #{task_name}"
        end

        clear_cassettes if options[:mode] == 'all' && options[:test_name].nil? && ENV['record'] != 'false'
        test_runner.run_tests(task_name, options)
        Rake::Task[:update_test_version].invoke if options[:mode] == 'all' && ENV['record'] != 'false'
      end
    end
  end
end

desc 'Updats the version of Pulp tested against in README'
task :update_test_version do
  text = File.open('README.md').read

  File.open('README.md', 'w+') do |file|
    original_regex = /Latest Live Tested Version: *.*/
    pulp_version = `rpm -q pulp-server`.strip
    replacement_string = "Latest Live Tested Version: **#{pulp_version}**"
    replace = text.gsub!(original_regex, replacement_string)
    file.puts replace
  end
end

desc 'Clears out all cassette files'
task :clear_cassettes do
  clear_cassettes
end

desc 'Runs all tests'
task :test do
  Rake::Task['test:unit'].invoke
  Rake::Task['test:models'].invoke
  Rake::Task['test:resources'].invoke
  Rake::Task['test:extensions'].invoke
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue
  puts "Rubocop not loaded"
end
