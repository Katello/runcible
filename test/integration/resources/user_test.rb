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


module TestResourcesUserBase
  def setup
    VCR.insert_cassette('user')
    @username = "integration_test_user"
    @resource = Runcible::Resources::User
  end

  def teardown
    VCR.eject_cassette
  end
end

class TestResourcesUserCreate < MiniTest::Unit::TestCase
  include TestResourcesUserBase

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

  def test_create
    response = @resource.create(@username)
    assert response.code == 201
    assert response['login'] == @username
  end

  def test_create_with_name_and_password
    response = @resource.create(@username, {:name => @username, :password => "integration_test_password"})
    assert response.code == 201
    assert response['name'] == @username
  end

end


class TestResourcesUser < MiniTest::Unit::TestCase
  include TestResourcesUserBase

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

  def test_path
    path = @resource.path
    assert_match("users/", path)
  end

  def test_path_with_username
    path = @resource.path(@username)
    assert_match("users/#{@username}", path)
  end

  def test_retrieve
    response = @resource.retrieve(@username)
    assert response.code == 200
    assert response["login"] == @username
  end

  def test_retrieve_all
    response = @resource.retrieve_all()
    assert response.code == 200
    assert !response.empty?
  end

  def test_delete
    response = @resource.delete(@username)
    assert response.code == 200
  end

end
