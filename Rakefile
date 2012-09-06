#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rake/testtask"

namespace :test do
  Rake::TestTask.new :unit do |t|
    t.pattern = 'test/unit/test_*.rb'
  end

  task :integration do
    options = {}

    options[:mode]      = ENV['mode']
    options[:test_name] = ENV['test']
    options[:auth_type] = ENV['auth_type']

    if !['recorded', 'live'].include?(options[:mode])
      puts "Invalid test mode"
    else
      require "test/integration/pulp/test_runner"

      test_runner = PulpMiniTestRunner.new

      if options[:test_name]
        puts "Running tests for: #{options[:test_name]}"
        puts "Using #{options[:mode]} Pulp."

        test_runner.run_tests(options)
      else
        puts "Running full test suite."
        puts "Using #{options[:mode]} data."

        test_runner.run_tests(options)
      end
    end
  end
end
