if RUBY_VERSION > "2.2"
  # Coverage - Keep these two lines at the top of this file
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter,
                          Coveralls::SimpleCov::Formatter]
  SimpleCov.start do
    minimum_coverage 90
    refuse_coverage_drop
    track_files "lib/**/*.rb"
    add_filter '/test/'
  end
end

require 'rubygems'
require 'logger'
require 'minitest/unit'
require 'minitest/autorun'
require 'mocha/setup'

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
        options = self.class.respond_to?(:cassette_options) ? self.class.cassette_options : {}
        VCR.insert_cassette(cassette_name, options)
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
        fail '@support or @@support not defined' unless support

        if response.key? "group_id"
          assert_async_task_groups(response, support)
        else
          assert_async_tasks(response, support)
        end
      end

      def assert_async_tasks(response, support)
        assert_equal 202, response.code
        tasks = support.wait_on_response(response)
        tasks.each do |task|
          assert task['state'], 'finished'
        end
      end

      def assert_async_task_groups(response, support)
        assert_equal 202, response.code
        summary = support.wait_on_task_group(response)
        assert_equal summary["total"], summary["finished"]
        summary
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
      options = suite.respond_to?(:cassette_options) ? suite.cassette_options : {}
      if logging?
        puts "Running Suite #{suite.inspect} - #{type.inspect} "
      end
      if suite.respond_to?(:before_suite)
        VCR.use_cassette(suite.suite_cassette_name, options) do
          suite.before_suite
        end
      end
      super(suite, type)
    ensure
      if suite.respond_to?(:after_suite)
        VCR.use_cassette(suite.suite_cassette_name, options) do
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
    config[:verify_ssl] = false
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
