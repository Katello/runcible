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
require 'test/integration/pulp/vcr_pulp_setup'
require 'lib/runcible/resources/user'


module TestPulpUserBase
  def setup
    VCR.insert_cassette('pulp_user')
    @username = "integration_test_user"
    @resource = Runcible::Pulp::User
  end

  def teardown
    VCR.eject_cassette
  end
end

class TestPulpUser < MiniTest::Unit::TestCase
  include TestPulpUserBase

  def teardown
    super
    VCR.use_cassette('pulp_user_helper') do
      begin
        @resource.find(@username)
        @resource.destroy(@username)
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
    assert_match("users/" + @username, path)
  end

  def test_find
    response = @resource.find("admin")
    assert response.length > 0
    assert "admin" == response["login"]
  end

  def test_create
    response = @resource.create(@username, @username, "integration_test_password")
    assert response.length > 0
  end
end


class TestPulpUserDestroy < MiniTest::Unit::TestCase
  include TestPulpUserBase

  def setup
    super
    VCR.use_cassette('pulp_user_helper') do
      begin
        @resource.find(@username)
      rescue RestClient::ResourceNotFound => e
        @resource.create(@username, @username, "integration_test_password")
      end
    end
  end

  def test_destroy
    response = @resource.destroy(@username)
    assert response == 200
  end

end
