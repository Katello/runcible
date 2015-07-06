require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'
require './lib/runcible'

module Resources
  module TestPuppetRepositoryBase
    def setup
      @resource = TestRuncible.server.resources.repository
      @extension = TestRuncible.server.extensions.repository
      @support = RepositorySupport.new
    end
  end

  class TestPuppetRepositoryRequiresSync < MiniTest::Unit::TestCase
    include TestPuppetRepositoryBase

    def setup
      super
      @support.create_and_sync_repo(:importer_and_distributor => true)
    end

    def teardown
      @support.destroy_repo
      super
    end

    def test_publish
      response = @resource.publish(RepositorySupport.repo_id, @support.distributor['id'])
      tasks = assert_async_response(response)

      assert_includes tasks.first['tags'], 'pulp:action:publish'
    end

    def test_unassociate_units
      response = @resource.unassociate_units(RepositorySupport.repo_id, {})
      assert_async_response(response)
    end

    def test_unit_search
      response = @resource.unit_search(RepositorySupport.repo_id, {})

      assert_equal 200, response.code
      refute_empty response
    end

    def test_sync_history
      response = @resource.sync_history(RepositorySupport.repo_id)

      assert 200, response.code
      refute_empty response
    end
  end
end
