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
require 'minitest/unit'
require 'minitest/autorun'

require './test/integration/vcr_setup'
require './lib/runcible/base'


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

  def run_tests(options={})
    mode      = options[:mode] || "recorded" 
    test_name = options[:test_name] || nil
    auth_type = options[:auth_type] || "http"
    logging   = options[:logging] || false

    MiniTest::Unit.runner = CustomMiniTestRunner::Unit.new

    if mode == "live"
      set_runcible_config({ :auth_type => auth_type, :logging => logging })
    else
      set_runcible_config({ :logging => logging })
    end

    set_vcr_config(mode)

    if test_name
      require "./test/integration/#{test_name}_test.rb"
    else
      Dir["./test/integration/resources/*_test.rb"].each {|file| require file }
      Dir["./test/integration/extensions/*_test.rb"].each {|file| require file }
    end
  end

  def set_runcible_config(options)
    Runcible::Base.config = {
      :api_path   => "/pulp/api/v2/",
      :http_auth  => {}
    }

    if options[:logging] == "true"
      Runcible::Base.config[:logger] = 'stdout'
    end

    if options[:auth_type] == "http"

      File.open('/etc/pulp/server.conf') do |f|
        f.each_line do |line|
          if line.start_with?('default_password')
            Runcible::Base.config[:http_auth][:password] = line.split(':')[1].strip
          elsif line.start_with?('default_login')
            Runcible::Base.config[:user] = line.split(':')[1].strip
          elsif line.start_with?('server_name')
            Runcible::Base.config[:url] = "https://#{line.split(':')[1].chomp.strip}"
          end
        end
      end
    elsif options[:auth_type] == "oauth"

      File.open('/etc/pulp/server.conf') do |f|
        f.each_line do |line|
          if line.start_with?('oauth_secret')
            Runcible::Base.config[:oauth][:oauth_secret] = line.split(':')[1].strip
          elsif line.start_with?('oauth_key')
            Runcible::Base.config[:oauth][:oauth_key] = line.split(':')[1].strip
          elsif line.start_with?('default_login')
            Runcible::Base.config[:user] = line.split(':')[1].strip
          elsif line.start_with?('server_name')
            Runcible::Base.config[:url] = "https://#{line.split(':')[1].chomp.strip}"
          end
        end
      end
    else
      Runcible::Base.config[:http_auth][:password] = 'admin'
      Runcible::Base.config[:user]  = 'admin'
      Runcible::Base.config[:url]   = "https://localhost"
    end
  end

  def set_vcr_config(mode)
    if mode == "live"
      configure_vcr(:all)
    elsif mode == "none"
      configure_vcr(:none)
    elsif mode == "once"
      configure_vcr(:once)
    else
      configure_vcr(:new_episodes)
    end
  end
end
