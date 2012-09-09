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
require './lib/runcible/resources/role'


class TestPulpRoles < MiniTest::Unit::TestCase
  def setup
    @username = "integration_test_user"
    @role_name = "super-users"
    @resource = Runcible::Pulp::Role

    VCR.use_cassette('pulp_user') do
      Runcible::Pulp::User.create(@username)
    end

    VCR.insert_cassette('pulp_role')
  end

  def teardown
    VCR.use_cassette('pulp_user') do
      Runcible::Pulp::User.delete(@username)
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
    assert response[:response_code] == 200
    @resource.remove(@role_name, @username)
  end

  def test_remove
    @resource.add(@role_name, @username)
    response = @resource.remove(@role_name, @username)
    assert response[:response_code] == 200
  end

end
