# Copyright (c) 2012 Red Hat
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
require 'minitest/autorun'
require 'minitest/mock'
require './lib/runcible/base'
require './test/support/logger_support'

module Base
  class TestBase < MiniTest::Unit::TestCase

    def setup
      @logger = ::Runcible::Logger.new
      @my_runcible = Runcible::Base.new ({
        :base_url => "http://localhost/",
        :user     => "test_user",
        :password => "test_password",
        :headers  => { :content_type => 'application/json',
                       :accept       => 'application/json' },
        :logging  => { :logger => @logger }
      })

      @log_message = 'Fake log message.'
      RestClient.log = [@log_message]
    end

    def test_config
      refute_nil @my_runcible.config
    end

    def test_process_response_returns_hash
      json = { :a => "test", :b => "data" }.to_json
      response = OpenStruct.new(:body => json)
      data = @my_runcible.process_response(response)

      assert_equal "test", data.body["a"]
    end

    def test_process_response_returns_string
      response = OpenStruct.new(:body => "true")
      data = @my_runcible.process_response(response)

      assert_equal "true", data.body
    end

    def test_verbose_logger
      @my_runcible.config[:logging][:debug] = true
      @my_runcible.log_debug

      assert_equal @log_message, @logger.message
    end

    def test_exception_logger
      @my_runcible.config[:logging][:exception]  = true
      @my_runcible.log_exception

      assert_equal @log_message, @logger.message
    end

    def test_generate_payload
      options = {:payload => "abc123"}
      assert_equal "abc123", @my_runcible.generate_payload(options)

      payload = {:required => {:a => "1",
                               :b => "2"
                              },
                 :optional => {:c => "3"
                              }
      }
      result = {:a => "1",
                :b => "2",
                :c => "3"
      }

      assert_equal result.to_json, @my_runcible.generate_payload(:payload => payload)
    end

  end
end