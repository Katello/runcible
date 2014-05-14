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
require 'minitest/autorun'

module Resources
  module TestUserBase
    def setup
      @username = "integration_test_user"
      @resource = TestRuncible.server.resources.user
    end
  end

  class TestUserCreate < MiniTest::Unit::TestCase
    include TestUserBase

    def teardown
      @resource.delete(@username)
    ensure
      super
    end

    def test_create
      response = @resource.create(@username)

      assert_equal 201, response.code
      assert_equal @username, response['login']
    end

    def test_create_with_name_and_password
      response = @resource.create(@username, {:name => @username, :password => "integration_test_password"})

      assert_equal 201, response.code
      assert_equal @username, response['name']
    end

  end


  class TestUser < MiniTest::Unit::TestCase
    include TestUserBase

    def setup
      super
      begin
        @resource.retrieve(@username)
      rescue RestClient::ResourceNotFound => e
        @resource.create(@username)
      end
    end

    def teardown
      @resource.delete(@username)
    rescue RestClient::ResourceNotFound => e
    ensure
      super
    end

    def test_path
      path = @resource.class.path

      assert_match "users/", path
    end

    def test_path_with_username
      path = @resource.class.path(@username)

      assert_match "users/#{@username}", path
    end

    def test_retrieve
      response = @resource.retrieve(@username)

      assert_equal 200, response.code
      assert_equal @username, response["login"]
    end

    def test_retrieve_all
      response = @resource.retrieve_all()

      assert_equal 200, response.code
      refute_empty response
    end

    def test_delete
      response = @resource.delete(@username)

      assert_equal 200, response.code
    end

  end
end