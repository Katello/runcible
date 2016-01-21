require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'
require './lib/runcible'

module Resources
  module TestRepositoryBase
    def setup
      @resource = TestRuncible.server.resources.repository
      @extension = TestRuncible.server.extensions.repository
      @support = RepositorySupport.new
    end

    def assert_async_response(response)
      if response.code == 202
        tasks = @support.wait_on_response(response)
        tasks.each do |task|
          assert task['state'], 'finished'
        end
      else
        assert response.code, 200
      end
    end
  end

  class TestRepositoryCreate < MiniTest::Unit::TestCase
    include TestRepositoryBase

    def setup
      super
    end

    def teardown
      @support.destroy_repo
      super
    end

    def test_create
      response = @support.create_repo

      assert_equal 201, response.code
      assert_equal RepositorySupport.repo_id, response['id']
    end
  end

  class TestRepositoryDelete < MiniTest::Unit::TestCase
    include TestRepositoryBase

    def setup
      super
      @support.create_repo
    end

    def test_delete
      response = @resource.delete(RepositorySupport.repo_id)
      @support.wait_on_response(response)

      assert_equal 202, response.code
    end
  end

  class TestRepositoryMisc < MiniTest::Unit::TestCase
    include TestRepositoryBase

    def setup
      super
      RepositorySupport.new.create_repo(:importer => true)
    end

    def teardown
      RepositorySupport.new.destroy_repo
    ensure
      super
    end

    def test_path
      path = @resource.class.path

      assert_match 'repositories/', path
    end

    def test_repository_path_with_id
      path = @resource.class.path(RepositorySupport.repo_id)

      assert_match "repositories/#{RepositorySupport.repo_id}", path
    end

    def test_update
      response = @resource.update(RepositorySupport.repo_id,
                                  :description => 'updated_description_' + RepositorySupport.repo_id)

      assert_equal 200, response.code
      assert_equal 'updated_description_' + RepositorySupport.repo_id, response['result']['description']
    end

    def test_retrieve
      response = @resource.retrieve(RepositorySupport.repo_id)

      assert_equal 200, response.code
      assert_equal RepositorySupport.repo_id, response['display_name']
    end

    def test_retrieve_all
      response = @resource.retrieve_all

      assert_equal 200, response.code
      refute_empty response
    end

    def test_search
      response = @resource.search({})

      assert_equal 200, response.code
      refute_empty response
    end

    def test_generate_applicability
      criteria  = {
        'repo_criteria' => { 'filters' => { 'id' => { '$in' => [RepositorySupport.repo_id] } } }
      }
      response = @resource.regenerate_applicability(criteria)
      assert_equal 202, response.code
      task = RepositorySupport.new.wait_on_response(response)
      assert 'finished', task.first['state']
    end
  end

  class TestRespositoryDistributor < MiniTest::Unit::TestCase
    include TestRepositoryBase
    def setup
      super
      @support.create_repo(:importer => false)
    end

    def teardown
      @support.destroy_repo
    ensure
      super
    end

    def test_associate_distributor
      distributor_config = {'relative_url' => '123/456', 'http' => true, 'https' => true}
      response = @resource.associate_distributor(RepositorySupport.repo_id, 'yum_distributor', distributor_config,
                                                 :distributor_id => 'dist_1')

      assert_equal 201, response.code
      assert_equal 'yum_distributor', response['distributor_type_id']
    end

    def test_delete_distributor
      distributor_config = {'relative_url' => '123/456', 'http' => true, 'https' => true}
      @resource.associate_distributor(RepositorySupport.repo_id, 'yum_distributor',
                                      distributor_config, :distributor_id => 'dist_1')

      response = @resource.delete_distributor(RepositorySupport.repo_id, 'dist_1')
      @support.wait_on_response(response)

      assert_equal 202, response.code
    end

    def test_update_distributor
      distributor_config = {'relative_url' => '123/456', 'http' => true, 'https' => true}
      distributor = @resource.associate_distributor(RepositorySupport.repo_id, 'yum_distributor',
                                      distributor_config, :distributor_id => 'dist_1')

      response = @resource.update_distributor(RepositorySupport.repo_id, distributor['id'],
                                           :relative_url => 'new_path/')
      assert_equal 202, response.code
    end
  end

  class TestRepositoryImporter < MiniTest::Unit::TestCase
    include TestRepositoryBase

    def setup
      super
      RepositorySupport.new.create_repo(:importer => false)
      associate
    end

    def teardown
      RepositorySupport.new.destroy_repo
    ensure
      super
    end

    def associate
      response = @resource.associate_importer(RepositorySupport.repo_id, 'yum_importer', {})
      assert_async_response(response)
    end

    def test_associate_importer
      repo = @resource.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal 'yum_importer', repo['importers'].first['id']
    end

    def test_delete_importer
      response = @resource.delete_importer(RepositorySupport.repo_id, 'yum_importer')
      assert_async_response(response)
    end

    def test_update_importer
      feed_url = 'http://katello.org/repo/'
      response = @resource.update_importer(RepositorySupport.repo_id, 'yum_importer',
                                           :feed => feed_url)

      assert_async_response(response)
      repo = @resource.retrieve(RepositorySupport.repo_id, :details => true)
      importer = repo[:importers].find { |imp| imp[:repo_id] == "integration_test_id" }
      assert_equal feed_url, importer[:config][:feed]
    end
  end

  class TestRepositorySync < MiniTest::Unit::TestCase
    include TestRepositoryBase

    def setup
      super
    end

    def teardown
      @support.destroy_repo
    ensure
      super
    end

    def test_sync
      @support.create_repo
      response = @resource.sync(RepositorySupport.repo_id)

      tasks = assert_async_response(response)
      assert_includes tasks.first['tags'], 'pulp:action:sync'
    end

    def test_sync_repo_with_yum_importer
      @support.create_repo(:importer => true)
      response = @resource.sync(RepositorySupport.repo_id)

      tasks = assert_async_response(response)
      assert_includes tasks.first['tags'], 'pulp:action:sync'
    end
  end

  class TestRepositoryRequiresSync < MiniTest::Unit::TestCase
    include TestRepositoryBase

    def setup
      super
      @support.create_and_sync_repo(:importer_and_distributor => true)
    end

    def teardown
      @support.destroy_repo
    ensure
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

  class TestRepositoryClone < MiniTest::Unit::TestCase
    include TestRepositoryBase

    def setup
      super
      @clone_name = RepositorySupport.repo_id + '_clone'
      @support.create_and_sync_repo(:importer => true)
      @extension.create_with_importer(@clone_name, :id => 'yum_importer')
    end

    def teardown
      @support.destroy_repo(@clone_name)
      @support.destroy_repo
    ensure
      super
    end

    def test_unit_copy
      response = @resource.unit_copy(@clone_name, RepositorySupport.repo_id)
      tasks = assert_async_response(response)

      assert_includes tasks.first['tags'], 'pulp:action:associate'
    end
  end
end
