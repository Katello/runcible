require 'rubygems'
require 'minitest/autorun'
require './lib/runcible/resources/consumer_group'
require './lib/runcible/extensions/consumer_group'
require './test/support/consumer_support'
require './test/support/consumer_group_support'
require './test/support/repository_support'

module Extensions
  class TestConsumerGroup < MiniTest::Unit::TestCase
    def self.before_suite
      @@repo_support = RepositorySupport.new
      @@consumer_support = ConsumerSupport.new
      @@group_support = ConsumerGroupSupport.new
      @@repo_support.create_and_sync_repo(:importer_and_distributor => true)
    end

    def self.after_suite
      @@repo_support.destroy_repo
    end

    def setup
      @resource = TestRuncible.server.resources.consumer_group
      @extension = TestRuncible.server.extensions.consumer_group

      @@group_support.create_consumer_group
      @@consumer_support.create_consumer

      criteria = {:criteria =>
                     {:filters =>
                       {:id => {'$in' => [ConsumerSupport.consumer_id]}}}}
      distro_id = @@repo_support.distributor['id']

      TestRuncible.server.extensions.consumer.bind(ConsumerSupport.consumer_id, RepositorySupport.repo_id, distro_id)
      @resource.associate(ConsumerGroupSupport.consumer_group_id, criteria)
      @consumer_group_id = ConsumerGroupSupport.consumer_group_id
    end

    def teardown
      @@consumer_support.destroy_consumer
      @@group_support.destroy_consumer_group
    end

    def test_add_consumers_by_id
      response = @extension.add_consumers_by_id(ConsumerGroupSupport.consumer_group_id, [ConsumerSupport.consumer_id])

      assert_equal 200, response.code
      refute_empty response
      assert_includes response, ConsumerSupport.consumer_id
    end

    def test_remove_consumers_by_id
      assert_includes(@resource.retrieve(ConsumerGroupSupport.consumer_group_id)['consumer_ids'],
                      ConsumerSupport.consumer_id)

      response = @extension.remove_consumers_by_id(ConsumerGroupSupport.consumer_group_id,
                                                   [ConsumerSupport.consumer_id])

      assert_equal 200, response.code
      assert_empty response # no consumers
      refute_includes(@resource.retrieve(ConsumerGroupSupport.consumer_group_id)['consumer_ids'],
                       ConsumerSupport.consumer_id)
    end

    def test_make_consumer_criteria
      criteria = @extension.make_consumer_criteria([ConsumerSupport.consumer_id])

      assert_kind_of Hash, criteria
      refute_empty criteria[:criteria][:filters][:id]['$in']
    end

    def test_install_content
      response = @extension.install_content(@consumer_group_id, 'rpm', ['zsh', 'foo'])

      assert_equal 202, response.code
      assert response['spawned_tasks'].first['task_id']
    end

    def test_update_content
      response = @extension.update_content(@consumer_group_id, 'rpm', ['zsh', 'foo'])

      assert_equal 202, response.code
      assert response['spawned_tasks'].first['task_id']
    end

    def test_uninstall_content
      response = @extension.uninstall_content(@consumer_group_id, 'rpm', ['zsh', 'foo'])

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
  end
end
