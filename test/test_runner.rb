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
  puts 'Debugging not enabled.'
end

class TestRuncible
  def self.server=(instance)
    @@instance = instance
  end

  def self.server
    @@instance
  end
end

module MiniTest
  class Unit
    class TestCase
      def cassette_name
        test_name = self.__name__.gsub('test_', '')
        parent = (self.class.name.split('::')[-2] || '').underscore
        self_class = self.class.name.split('::')[-1].underscore.gsub('test_', '')
        "#{parent}/#{self_class}/#{test_name}"
      end

      def run_with_vcr(args)
        VCR.insert_cassette(cassette_name)
        to_ret = run_without_vcr(args)
        VCR.eject_cassette
        to_ret
      end

      alias_method_chain :run, :vcr

      class << self
        attr_accessor :support

        def suite_cassette_name
          parent = (self.name.split('::')[-2] || '').underscore
          self_class = self.name.split('::')[-1].underscore.gsub('test_', '')
          "#{parent}/#{self_class}/suite"
        end
      end

      def assert_async_response(response)
        support = @support || self.class.support
        fail '@support or @@supsport not defined' unless support

        assert_equal 202, response.code
        tasks = support.wait_on_response(response)
        tasks.each do |task|
          assert task['state'], 'finished'
        end
      end
    end
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

    def _run_suite(suite, type)
      if logging?
        puts "Running Suite #{suite.inspect} - #{type.inspect} "
      end
      if suite.respond_to?(:before_suite)
        VCR.use_cassette(suite.suite_cassette_name) do
          suite.before_suite
        end
      end
      super(suite, type)
    ensure
      if suite.respond_to?(:after_suite)
        VCR.use_cassette(suite.suite_cassette_name) do
          suite.after_suite
        end
      end
      if logging?
        puts "Completed Running Suite #{suite.inspect} - #{type.inspect} "
      end
    end

    def logging?
      ENV['logging']
    end
  end
end

class PulpMiniTestRunner
  def run_tests(suite, options = {})
    mode      = options[:mode] || 'none'
    test_name = options[:test_name] || nil
    auth_type = options[:auth_type] || 'http'
    logging   = options[:logging] || false

    MiniTest::Unit.runner = CustomMiniTestRunner::Unit.new

    if mode == 'all'
      runcible_config(:auth_type => auth_type, :logging => logging)
    else
      runcible_config(:logging => logging)
    end

    vcr_config(mode)

    if test_name && File.exist?(test_name)
      require test_name
    elsif test_name
      require "./test/#{test_name}_test.rb"
    else
      Dir["./test/#{suite}/*_test.rb"].each { |file| require file }
    end
  end

  def runcible_config(options)
    config = { :api_path   => '/pulp/api/v2/',
               :http_auth  => {}}

    if options[:logging] == 'true'
      log = ::Logger.new(STDOUT)
      log.level = Logger::DEBUG
      config[:logging] = { :logger => log,
                           :debug  => true,
                           :stdout => true}
    end

    if options[:auth_type] == 'http'

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
    elsif options[:auth_type] == 'oauth'

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
      config[:url]   = 'https://localhost'
    end

    TestRuncible.server = Runcible::Instance.new(config)
  end

  def vcr_config(mode)
    if mode == 'all'
      configure_vcr(:all)
    elsif mode == 'new_episodes'
      configure_vcr(:new_episodes)
    elsif mode == 'once'
      configure_vcr(:once)
    else
      configure_vcr(:none)
    end
  end
end
