#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rake/testtask"

def clear_cassettes
  `rm -rf test/fixtures/vcr_cassettes/*.yml`
  `rm -rf test/fixtures/vcr_cassettes/extensions/*.yml`
  `rm -rf test/fixtures/vcr_cassettes/support/*.yml`
  print "Cassettes cleared\n"
end


namespace :test do
  "Runs the unit tests"
  Rake::TestTask.new :unit do |t|
    t.pattern = 'test/unit/test_*.rb'
  end

  [:resources, :extensions].each do |task_name|
    desc "Runs the #{task_name} tests"
    task task_name do
      options = {}

      options[:mode]      = ENV['mode'] || 'none'
      options[:test_name] = ENV['test']
      options[:auth_type] = ENV['auth_type']
      options[:logging]   = ENV['logging']

      if !['new_episodes', 'all', 'none', 'once'].include?(options[:mode])
        puts "Invalid test mode"
      else
        require "./test/test_runner"

        test_runner = PulpMiniTestRunner.new

        if options[:test_name]
          puts "Running tests for: #{options[:test_name]}"
        else
          puts "Running tests for: #{task_name}"
        end

        clear_cassettes if options[:mode] == 'all' && options[:test_name].nil?
        test_runner.run_tests(task_name, options)
        Rake::Task[:update_test_version].invoke if options[:mode] == "all" && ENV['record'] != false
      end
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

desc "Finds functions without dedicated tests"
task :untested do
  test_functions  = `grep -r 'def test_' test/ --exclude-dir=test/fixtures --include=*.rb --no-filename` 
  lib_functions   = `grep -r 'def self' lib/ --exclude=base.rb --include=*.rb --no-filename`
  
  test_functions  = test_functions.split("\n").map{ |str| str.strip.split("def test_")[1] }.to_set
  lib_functions   = lib_functions.split("\n").map{ |str| str.strip.split("def self.")[1].split("(").first }.to_set

  difference = (lib_functions - test_functions).to_a

  if !difference.empty?
    puts difference
    exit 1 
  end
end

desc "Clears out all cassette files"
task :clear_cassettes do
  clear_cassettes
end

desc "Runs all tests"
task :test do
  Rake::Task['test:unit'].invoke
  Rake::Task['test:resources'].invoke
  Rake::Task['test:extensions'].invoke
end
