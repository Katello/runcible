# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'rubygems'
require 'minitest/unit'
require 'minitest/autorun'

require 'test/integration/vcr_setup'
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
        suite.before_suite if suite.respond_to?(:before_suite)
        super(suite, type)
      ensure
        suite.after_suite if suite.respond_to?(:after_suite)
      end
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
      require "test/integration/#{test_name}_test.rb"
    else
      Dir["test/integration/resources/*_test.rb"].each {|file| require file }
      Dir["test/integration/extensions/*_test.rb"].each {|file| require file }
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
