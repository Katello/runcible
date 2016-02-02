require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'
require './lib/runcible'

module Extensions
  module TestRepositoryBase
    def setup
      @support = RepositorySupport.new
      @extension = TestRuncible.server.extensions.repository
    end
  end

  class TestRepositoryCreate < MiniTest::Unit::TestCase
    include TestRepositoryBase

    def setup
      super
      @support.destroy_repo
    end

    def teardown
      super
      @support.destroy_repo
    end

    def test_create_with_importer
      response = @extension.create_with_importer(RepositorySupport.repo_id, :id => 'yum_importer')
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'yum_importer', response['importers'].first['importer_type_id']
    end

    def test_create_with_importer_object
      response = @extension.create_with_importer(RepositorySupport.repo_id, Runcible::Models::YumImporter.new)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'yum_importer', response['importers'].first['importer_type_id']
    end

    def test_create_with_distributors
      distributors = [{'type_id' => 'yum_distributor', 'id' => '123', 'auto_publish' => true,
                       'config' => {'relative_url' => 'path', 'http' => true, 'https' => true}}]
      response = @extension.create_with_distributors(RepositorySupport.repo_id, distributors)

      assert_equal 201, response.code
      assert_equal RepositorySupport.repo_id, response['id']
    end

    def test_create_with_distributor_object
      repo_id = RepositorySupport.repo_id + '_distro'
      response = @extension.create_with_distributors(repo_id, [Runcible::Models::YumDistributor.new(
          'path', true, true, :id => '123')])
      assert_equal 201, response.code

      response = @extension.retrieve(repo_id, :details => true)
      assert_equal repo_id, response['id']
      assert_equal 'yum_distributor', response['distributors'].first['distributor_type_id']
    ensure
      @support.destroy_repo(repo_id)
    end

    def test_create_with_importer_and_distributors
      distributors = [{'type_id' => 'yum_distributor', 'id' => '123', 'auto_publish' => true,
                       'config' => {'relative_url' => '123/456', 'http' => true, 'https' => true}}]
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id,
                                                                  {:id => 'yum_importer'}, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'yum_distributor', response['distributors'].first['distributor_type_id']
    end

    def test_create_with_importer_and_distributors_objects
      distributors = [Runcible::Models::YumDistributor.new(
              'path', true, true, :id => '123')]
      importer = Runcible::Models::YumImporter.new
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id, importer, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'yum_importer', response['importers'].first['importer_type_id']
    end
  end

  class TestRepositoryMisc < MiniTest::Unit::TestCase
    def self.before_suite
      self.support = RepositorySupport.new
      self.support.create_and_sync_repo(:importer_and_distributor => true)
    end

    def self.after_suite
      self.support.destroy_repo
    end

    def setup
      @extension = TestRuncible.server.extensions.repository
    end

    def test_search_by_repository_ids
      response = @extension.search_by_repository_ids([RepositorySupport.repo_id])

      assert_equal 200, response.code
      refute_empty response.map { |repo| repo['display_name'] == RepositorySupport.repo_id }
    end

    def test_create_or_update_schedule
      response = @extension.create_or_update_schedule(RepositorySupport.repo_id, 'yum_importer', '2012-09-25T20:44:00Z/P7D')
      assert_equal 201, response.code

      response = @extension.create_or_update_schedule(RepositorySupport.repo_id, 'yum_importer', '2011-09-25T20:44:00Z/P7D')
      assert_equal 200, response.code
    end

    def test_remove_schedules
      TestRuncible.server.resources.repository_schedule.create(RepositorySupport.repo_id, 'yum_importer', '2012-10-25T20:44:00Z/P7D')
      response = @extension.remove_schedules(RepositorySupport.repo_id, 'yum_importer')

      assert_equal 200, response.code
    end

    def test_retrieve_with_details
      response = @extension.retrieve_with_details(RepositorySupport.repo_id)

      assert_equal 200, response.code
      assert_includes response, 'distributors'
    end

    def test_publish_all
      responses = @extension.publish_all(RepositorySupport.repo_id)
      assert_equal 1, responses.length
      responses.each do |response|
        tasks = assert_async_response(response)
        assert_includes tasks.first['tags'], 'pulp:action:publish'
      end
    end

    def test_publish_status
      response = @extension.publish_status(RepositorySupport.repo_id)
      assert_equal 200, response.code
    end

    def test_sync_status
      response = @extension.sync_status(RepositorySupport.repo_id)

      assert_equal 200, response.code
    end

    def test_generate_applicability_by_ids_with_spawned_tasks
      response = @extension.regenerate_applicability_by_ids([RepositorySupport.repo_id], false)
      refute response.key?("group_id")
      tasks = assert_async_response(response)
      assert_equal 'finished', tasks.first['state']
    end

    def test_generate_applicability_by_ids_with_task_groups
      response = @extension.regenerate_applicability_by_ids([RepositorySupport.repo_id], true)
      assert response.key?("group_id")
      assert_async_response(response)
    end
  end

  class TestRepositoryUnitList < MiniTest::Unit::TestCase
    def self.before_suite
      @@extension = TestRuncible.server.extensions.repository
      self.support = RepositorySupport.new
      self.support.destroy_repo
      self.support.create_and_sync_repo(:importer => true)
    end

    def self.after_suite
      self.support.destroy_repo
    end

    def test_rpm_ids
      response = @@extension.rpm_ids(RepositorySupport.repo_id)

      refute_empty response
      assert_kind_of String, response.first
    end

    def test_rpms
      response = @@extension.rpms(RepositorySupport.repo_id)

      refute_empty response
      assert_kind_of Hash, response.first
    end

    def test_errata_ids
      response = @@extension.errata_ids(RepositorySupport.repo_id)
      refute_empty response
    end

    def test_errata
      response = @@extension.errata(RepositorySupport.repo_id)
      refute_empty response
    end

    def test_distributions
      response = @@extension.distributions(RepositorySupport.repo_id)

      refute_empty response
    end

    def test_package_groups
      response = @@extension.package_groups(RepositorySupport.repo_id)

      refute_empty response
    end

    def test_package_categories
      response = @@extension.package_categories(RepositorySupport.repo_id)

      refute_empty response
    end

    def test_rpms_by_name
      list = @@extension.rpms(RepositorySupport.repo_id)
      rpm = list.first
      response = @@extension.rpms_by_nvre(RepositorySupport.repo_id, rpm['name'])

      refute_empty response
    end

    def test_rpms_by_nvre
      list = @@extension.rpms(RepositorySupport.repo_id)
      rpm = list.first
      response = @@extension.rpms_by_nvre(RepositorySupport.repo_id, rpm['name'], rpm['version'],
                                              rpm['release'], rpm['epoch'])

      refute_empty response
    end
  end
end
