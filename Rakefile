#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rake/testtask"

namespace :test do
  "Runs the unit tests"
  Rake::TestTask.new :unit do |t|
    t.pattern = 'test/unit/test_*.rb'
  end

  desc "Runs the resources and extensions integration tests"
  task :integration do
    options = {}

    options[:mode]      = ENV['mode'] || 'none'
    options[:test_name] = ENV['test']
    options[:auth_type] = ENV['auth_type']
    options[:logging]   = ENV['logging']

    if !['new_episodes', 'live', 'none', 'once'].include?(options[:mode])
      puts "Invalid test mode"
    else
      require "test/integration/test_runner"

      test_runner = PulpMiniTestRunner.new

      if options[:test_name]
        puts "Running tests for: #{options[:test_name]}"
        puts "Using #{options[:mode]} Pulp."
      else
        puts "Running full test suite."
        puts "Using #{options[:mode]} data."
      end

      test_runner.run_tests(options)
      Rake::Task[:update_test_version].invoke if options[:mode] == "live"
    end
  end
end

desc "Updats the version of Pulp tested against in README"
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
