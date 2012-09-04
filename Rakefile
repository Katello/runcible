#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rake/testtask"
require "test/integration/pulp/test_runner"

namespace :test do
  task :integration do
    live = ENV['live']
    test_name = ENV['test']

    if live && test_name
      puts "Running tests for: #{test_name}"
      puts "Using live Pulp."

      system("test/integration/pulp/test_runner.rb --live #{test_name}")
    elsif live && !test_name
      puts "Running full test suite."
      puts "Using live Pulp."
      
      system("test/integration/pulp/test_runner.rb --live")
    elsif test_name && !live
      puts "Running tests for: #{test_name}"
      puts "Using recorded data."
      
      system("test/integration/pulp/test_runner.rb #{test_name}")
    else
      puts "Running full test suite."
      puts "Using recorded data."

      test_runner = PulpMiniTestRunner.new
      test_runner.run_tests(:recorded, "user")
    end
  end
end
