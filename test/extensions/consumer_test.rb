require 'rubygems'
require 'minitest/autorun'
require './lib/runcible/resources/consumer'
require './lib/runcible/extensions/consumer'
require './test/support/repository_support'
require './test/support/consumer_support'

module Extensions
  class TestConsumer < MiniTest::Unit::TestCase
    def self.before_suite
      @@repo_support = RepositorySupport.new
      @@consumer_support = ConsumerSupport.new
      @@repo_support.create_and_sync_repo(:importer_and_distributor => true)
    end

    def self.after_suite
      @@repo_support.destroy_repo
    end

    def setup
      @resource = TestRuncible.server.resources.consumer
      @extension = TestRuncible.server.extensions.consumer
      @consumer_id = 'integration_test_consumer_extensions11000'
      @@consumer_support.destroy_consumer
      @@consumer_support.create_consumer(true)
      @consumer_id = ConsumerSupport.consumer_id
      bind_repo
    end

    def teardown
      @@consumer_support.destroy_consumer
    end

    def bind_repo
      response = @extension.bind_all(@consumer_id, RepositorySupport.repo_id,
                                  Runcible::Models::YumDistributor.type_id, :notify_agent => false)
      @@repo_support.wait_on_response(response.first)
    end

    def test_activate_node
      response = @extension.activate_node(@consumer_id)
      refute_empty response
    end

    def test_deactivate_node
      @extension.activate_node(@consumer_id)
      response = @extension.deactivate_node(@consumer_id)
      refute_empty response
    end

    def test_bind_all
      @extension.unbind_all(@consumer_id, RepositorySupport.repo_id, Runcible::Models::YumDistributor.type_id)
      response = @extension.bind_all(@consumer_id, RepositorySupport.repo_id,
                                     Runcible::Models::YumDistributor.type_id, :notify_agent => false)
      assert_equal 200, response.first.code
    end

    def test_unbind_all
      response = @extension.unbind_all(@consumer_id, RepositorySupport.repo_id,
                                       Runcible::Models::YumDistributor.type_id)

      assert_equal 200, response.first.code
    end

    def test_install_content
      response = @extension.install_content(@consumer_id, 'rpm', ['zsh', 'foo'])

      assert_equal 202, response.code
      assert response['spawned_tasks'].first['task_id']
    end

    def test_update_content
      response = @extension.update_content(@consumer_id, 'rpm', ['zsh', 'foo'])

      assert_equal 202, response.code
      assert response['spawned_tasks'].first['task_id']
    end

    def test_uninstall_content
      response = @extension.uninstall_content(@consumer_id, 'rpm', ['zsh', 'foo'])

      assert_equal 202, response.code
      assert response['spawned_tasks'].first['task_id']
    end

    def test_generate_content
      content = @extension.generate_content('rpm', ['unit_1', 'unit_2'])

      refute_empty content
      refute_empty content.select { |unit| unit[:type_id] == 'rpm' }
    end

    def test_generate_content_all
      content = @extension.generate_content('rpm', ['unit_1'], :all => true)

      refute_empty content
      assert_equal 'rpm', content.first[:type_id]
      assert_empty content.first[:unit_key]
    end

    def test_generate_applicability_by_ids
      response = @extension.regenerate_applicability_by_ids([@consumer_id])

      assert_equal 202, response.code
      tasks = RepositorySupport.new.wait_on_response(response)
      assert 'finished', tasks.first['state']
    end

    def test_applicable_errata
      response  = @extension.applicable_errata([@consumer_id])

      assert_equal 200, response.code
    end
  end

  class TestConsumerApplicabilityScenario < MiniTest::Unit::TestCase
    def self.before_suite
      @@repo_support = RepositorySupport.new
      @@consumer_support = ConsumerSupport.new
      @@repo_support.create_and_sync_repo(:importer_and_distributor => true)
    end

    def self.after_suite
      @@repo_support.destroy_repo
    end

    def setup
      @extension = TestRuncible.server.extensions.consumer
      @consumer_id = 'integration_test_consumer_extensions11000'
      @@consumer_support.destroy_consumer
      @@consumer_support.create_consumer(false)
      @consumer_id = ConsumerSupport.consumer_id
      bind_repo
    end

    def test_applicability
      @extension.upload_profile(@consumer_id, 'rpm', [{'name' => 'elephant', 'version' => '0.2', 'release' => '0.7',
                                                       'epoch' => 0, 'arch' => 'noarch', 'vendor' => 'Fedora'}])
      task = @extension.regenerate_applicability_by_ids([@consumer_id])
      RepositorySupport.new.wait_on_response(task)
      applicability = @extension.applicable_errata([@consumer_id])

      refute_empty applicability
      assert applicability[0]['consumers'].include?(@consumer_id)
      refute_empty applicability[0]['applicability']['erratum']
    end

    def bind_repo
      tasks = @extension.bind_all(@consumer_id, RepositorySupport.repo_id,
                                  Runcible::Models::YumDistributor.type_id, :notify_agent => false)
      @@repo_support.wait_on_response(tasks.first)
    end
  end
end
