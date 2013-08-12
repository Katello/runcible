# Copyright 2012 Red Hat, Inc.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'rubygems'
require 'logger'
require 'minitest/unit'
require 'minitest/autorun'
require 'mocha'

require './test/vcr_setup'
require './lib/runcible'


begin
  require 'debugger'
rescue LoadError
  puts "Debugging not enabled."
end

class TestRuncible
  def self.server=(instance)
    @@instance = instance
  end

  def self.server
    @@instance
  end
end


class CustomMiniTestRunner
  class Unit < MiniTest::Unit

    def before_suites
      # code to run before the first test
    end

    def after_suites
      # code to run after the last test
    end

    def _run_suites(suites, type)
      begin
        if ENV['suite']
          suites = suites.select do |suite|
                     suite.name == ENV['suite']
                   end
        end

        before_suites
        super(suites, type)
      ensure
        after_suites
      end
    end

    def _run_suite(suite, type)
      begin
        if logging?
          puts "Running Suite #{suite.inspect} - #{type.inspect} "
        end

        suite.before_suite if suite.respond_to?(:before_suite)
        super(suite, type)
      ensure
        suite.after_suite if suite.respond_to?(:after_suite)
        if logging?
          puts "Completed Running Suite #{suite.inspect} - #{type.inspect} "
        end
      end
    end

    def logging?
      ENV['logging']
    end

  end
end


class PulpMiniTestRunner

  def run_tests(suite, options={})
    mode      = options[:mode] || "none"
    test_name = options[:test_name] || nil
    auth_type = options[:auth_type] || "http"
    logging   = options[:logging] || false

    MiniTest::Unit.runner = CustomMiniTestRunner::Unit.new

    if mode == "all"
      set_runcible_config({ :auth_type => auth_type, :logging => logging })
    else
      set_runcible_config({ :logging => logging })
    end

    set_vcr_config(mode)

    if test_name && File.exists?(test_name)
      require test_name
    elsif test_name
      require "./test/#{test_name}_test.rb"
    else
      Dir["./test/#{suite}/*_test.rb"].each {|file| require file }
    end
  end

  def set_runcible_config(options)
    config = {
      :api_path   => "/pulp/api/v2/",
      :http_auth  => {}
    }

    if options[:logging] == "true"
      log = ::Logger.new(STDOUT)
      log.level = Logger::DEBUG
      config[:logging] = {
        :logger => log,
        :debug  => true,
	      :stdout => true
      }
    end

    if options[:auth_type] == "http"

      File.open('/etc/pulp/server.conf') do |f|
        f.each_line do |line|
          if line.start_with?('default_password')
            config[:http_auth][:password] = line.split(':')[1].strip
          elsif line.start_with?('default_login')
            config[:user] = line.split(':')[1].strip
          elsif line.start_with?('server_name')
           config[:url] = "https://#{line.split(':')[1].chomp.strip}"
          end
        end
      end
    elsif options[:auth_type] == "oauth"

      File.open('/etc/pulp/server.conf') do |f|
        f.each_line do |line|
          if line.start_with?('oauth_secret')
            config[:oauth][:oauth_secret] = line.split(':')[1].strip
          elsif line.start_with?('oauth_key')
           config[:oauth][:oauth_key] = line.split(':')[1].strip
          elsif line.start_with?('default_login')
           config[:user] = line.split(':')[1].strip
          elsif line.start_with?('server_name')
           config[:url] = "https://#{line.split(':')[1].chomp.strip}"
          end
        end
      end
    else
      config[:http_auth][:password] = 'admin'
      config[:user]  = 'admin'
      config[:url]   = "https://localhost"
    end

    TestRuncible.server = Runcible::Instance.new(config)
  end

  def set_vcr_config(mode)
    if mode == "all"
      configure_vcr(:all)
    elsif mode == "new_episodes"
      configure_vcr(:new_episodes)
    elsif mode == "once"
      configure_vcr(:once)
    else
      configure_vcr(:none)
    end
  end
end
