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
require './lib/runcible/resources/user'
require './lib/runcible/extensions/user'

module TestExtensionsUserBase
  def setup
    VCR.insert_cassette('user')
    @username = "integration_test_user_extension"
    @extension = Runcible::Extensions::User
    @resource = Runcible::Resources::User
  end

  def teardown
    VCR.eject_cassette
  end
end


class TestExtensionsUser < MiniTest::Unit::TestCase
  include TestExtensionsUserBase

  def setup
    super
    VCR.use_cassette('user_support') do
      begin
        @resource.retrieve(@username)
      rescue RestClient::ResourceNotFound => e
        @resource.create(@username)
      end
    end
  end

  def teardown
    super
    VCR.use_cassette('user_support') do
      begin
        @resource.retrieve(@username)
        @resource.delete(@username)
      rescue RestClient::ResourceNotFound => e
      end
    end
  end

  def test_user_exists
    assert(@extension.exists?(@username))
  end

  def test_user_not_exists
    assert(!@extension.exists?("not" + @username))
  end
end
