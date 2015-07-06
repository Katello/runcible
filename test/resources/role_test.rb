require 'rubygems'
require 'minitest/autorun'

require './lib/runcible/resources/user'
require './lib/runcible/resources/role'

module Resources
  class TestRoles < MiniTest::Unit::TestCase
    def setup
      @username = 'integration_test_user'
      @role_name = 'super-users'
      @resource = TestRuncible.server.resources.role

      TestRuncible.server.resources.user.create(@username)
    end

    def teardown
      TestRuncible.server.resources.user.delete(@username)
    end

    def test_path_without_role_name
      path = @resource.class.path

      assert_match 'roles/', path
    end

    def test_path_with_role_name
      path = @resource.class.path(@role_name)

      assert_match "roles/#{@role_name}", path
    end

    def test_add
      skip 'TODO: should be removed when https://pulp.plan.io/issues/1078 is fixed'
      response = @resource.add(@role_name, @username)

      assert_equal 200, response.code
      @resource.remove(@role_name, @username)
    end

    def test_remove
      skip 'TODO: should be removed when https://pulp.plan.io/issues/1078 is fixed'
      @resource.add(@role_name, @username)
      response = @resource.remove(@role_name, @username)

      assert_equal 200, response.code
    end
  end
end
