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
    VCR.use_cassette('user_helper') do
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
    VCR.use_cassette('user_helper') do
      begin
        @resource.retrieve(@username)
      rescue RestClient::ResourceNotFound => e
        @resource.create(@username)
      end
    end
  end

  def teardown
    super
    VCR.use_cassette('user_helper') do
      begin
        @resource.retrieve(@username)
        @resource.delete(@username)
      rescue RestClient::ResourceNotFound => e
      end
    end
  end

  def test_path_without_username
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
