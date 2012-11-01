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
require './lib/runcible/resources/role'


class TestResourcesRoles < MiniTest::Unit::TestCase
  def setup
    @username = "integration_test_user"
    @role_name = "super-users"
    @resource = Runcible::Resources::Role

    VCR.use_cassette('user') do
      Runcible::Resources::User.create(@username)
    end

    VCR.insert_cassette('role')
  end

  def teardown
    VCR.use_cassette('user') do
      Runcible::Resources::User.delete(@username)
    end

    VCR.eject_cassette
  end

  def test_path_without_role_name
    path = @resource.path
    assert_match("roles/", path)
  end

  def test_path_with_role_name
    path = @resource.path(@role_name)
    assert_match("roles/#{@role_name}", path)
  end

  def test_add
    response = @resource.add(@role_name, @username)
    assert response.code == 200
    @resource.remove(@role_name, @username)
  end

  def test_remove
    @resource.add(@role_name, @username)
    response = @resource.remove(@role_name, @username)
    assert response.code == 200
  end

end
