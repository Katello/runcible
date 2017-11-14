require 'rubygems'
require 'minitest/autorun'

require './lib/runcible/resources/consumer'
require './lib/runcible/extensions/consumer'
require './test/support/repository_support'
require './test/support/consumer_support'

module Resources
  module TestConsumerBase
    def setup
      @resource = TestRuncible.server.resources.consumer
      @extension = TestRuncible.server.extensions.consumer
      @consumer_id = 'integration_test_consumer'
    end

    def create_consumer(package_profile = false)
      consumer = @resource.create(@consumer_id, :name => 'boo')
      if package_profile
        @consumer_resource.upload_profile(@consumer_id, 'rpm', [{'name' => 'elephant', 'version' => '0.2',
                                                                 'release' => '0.7', 'epoch' => 0, 'arch' => 'noarch'}])
      end
      consumer
    end

    def destroy_consumer
      @resource.delete(@consumer_id)
    rescue
    end
  end

  class ConsumerTests < MiniTest::Unit::TestCase
    include TestConsumerBase

    def setup
      super
      create_consumer
    end

    def teardown
      destroy_consumer
      super
    end
  end

  class TestConsumerCreate < MiniTest::Unit::TestCase
    include TestConsumerBase

    def teardown
      destroy_consumer
      super
    end

    def test_create
      response = create_consumer

      assert response.is_a? Hash
      assert_equal @consumer_id, response['consumer']['id']
    end
  end

  class TestConsumerDestroy < MiniTest::Unit::TestCase
    include TestConsumerBase

    def setup
      super
      create_consumer
    end

    def test_destroy
      response = destroy_consumer

      assert_equal 200, response.code
    end
  end

  class TestGeneralMethods < MiniTest::Unit::TestCase
    include TestConsumerBase

    def setup
      super
      create_consumer
    end

    def teardown
      destroy_consumer
      super
    end

    def test_path
      path = @resource.path

      assert_match 'consumers/', path
    end

    def test_consumer_path_with_id
      path = @resource.path(@consumer_id)

      assert_match "consumers/#{@consumer_id}/", path
    end

    def test_retrieve
      response = @resource.retrieve(@consumer_id)

      refute_empty response
      assert_equal @consumer_id, response['id']
    end

    def test_retrieve_all
      response = @resource.retrieve_all

      refute_empty response
      consumer_ids = response.map { |consumer| consumer['id'] }
      assert_includes consumer_ids, @consumer_id
    end

    def test_update
      description = 'Test description'
      response = @resource.update(@consumer_id, :description => description)

      assert_equal 200, response.code
      assert_equal description, response['description']
    end
  end

  class TestConsumerApplicability < MiniTest::Unit::TestCase
    include TestConsumerBase

    def setup
      super
      create_consumer
    end

    def teardown
      destroy_consumer
      super
    end

    def test_generate_applicability
      criteria = {
        'consumer_criteria' => { 'filters' => { 'id' => { '$in' => [@consumer_id] } } }
      }

      response = @resource.regenerate_applicability(criteria)
      assert_equal 202, response.code
      task = RepositorySupport.new.wait_on_response(response)
      assert 'finished', task.first['state']
    end

    def test_generate_applicability_one_id
      response = @resource.regenerate_applicability_by_id(@consumer_id)
      assert_equal 202, response.code
      task = RepositorySupport.new.wait_on_response(response)
      assert 'finished', task.first['state']
    end

    def test_applicability
      criteria = {
        'criteria' => { 'filters' => { 'id' => { '$in' => [@consumer_id] } } },
        'content_types' => [Runcible::Extensions::Errata.content_type]
      }
      response = @resource.applicability(criteria)

      assert_equal 200, response.code
    end
  end

  class TestProfiles < MiniTest::Unit::TestCase
    include TestConsumerBase

    def setup
      super
      create_consumer
    end

    def teardown
      destroy_consumer
      super
    end

    def test_upload_profile
      packages = [{'vendor' => 'FedoraHosted', 'name' => 'elephant',
                   'version' => '0.3', 'release' => '0.8',
                   'arch' => 'noarch', 'epoch' => ''}]
      response = @resource.upload_profile(@consumer_id, 'rpm', packages)

      assert_equal 201, response.code
    end

    def test_retrieve_profile
      packages = [{'vendor' => 'FedoraHosted', 'name' => 'elephant',
                   'version' => '0.3', 'release' => '0.8',
                   'arch' => 'noarch', 'epoch' => '1'}]
      @resource.upload_profile(@consumer_id, 'rpm', packages)
      response = @resource.retrieve_profile(@consumer_id, 'rpm')

      assert_equal @consumer_id, response['consumer_id']
      assert_equal packages, response['profile']
    end
  end

  class ConsumerRequiresRepoTests < MiniTest::Unit::TestCase
    include TestConsumerBase
    def self.before_suite
      @@support = ConsumerSupport.new
      @@repo_support = RepositorySupport.new
      @@support.create_consumer(true)
      @@repo_support.create_and_sync_repo(:importer_and_distributor => true)
    end

    def self.after_suite
      @@support.destroy_consumer
      @@repo_support.destroy_repo
    end

    def self.bind_repo
      distro_id = @@repo_support.distributor['id']
      tasks = TestRuncible.server.resources.consumer.bind(ConsumerSupport.consumer_id,
                                    RepositorySupport.repo_id, distro_id, :notify_agent => false)
      @@repo_support.wait_on_response(tasks)
      return tasks
    end
  end

  class TestConsumerBindings < ConsumerRequiresRepoTests
    def test_bind
      response = self.class.bind_repo

      refute_empty response
      assert_equal 200, response.code
    end

    def test_unbind
      self.class.bind_repo
      distro_id = @@repo_support.distributor['id']
      refute_empty @resource.retrieve_bindings(ConsumerSupport.consumer_id)

      response = @resource.unbind(ConsumerSupport.consumer_id, RepositorySupport.repo_id, distro_id)

      assert_equal 200, response.code
    end
  end

  class TestConsumerRequiresRepo < ConsumerRequiresRepoTests
    def self.before_suite
      super
      bind_repo
    end

    def test_retrieve_binding
      distributor_id = @@repo_support.distributor['id']
      response = @resource.retrieve_binding(ConsumerSupport.consumer_id, RepositorySupport.repo_id, distributor_id)

      assert_equal 200, response.code
      assert_equal RepositorySupport.repo_id, response['repo_id']
    end

    def test_retrieve_bindings
      response = @resource.retrieve_bindings(ConsumerSupport.consumer_id)

      assert_equal 200, response.code
      refute_empty response
    end

    def test_install_units
      response = @resource.install_units(ConsumerSupport.consumer_id,
                                          [{'unit_key' => {:name => 'zsh'}, :type_id => 'rpm'}])
      assert_equal 202, response.code
      refute_empty response
    end

    def test_update_units
      response = @resource.update_units(ConsumerSupport.consumer_id,
                                        [{'unit_key' => {:name => 'zsh'}, :type_id => 'rpm'}])
      assert_equal 202, response.code
      refute_empty response
    end

    def test_uninstall_units
      response = @resource.uninstall_units(ConsumerSupport.consumer_id,
                                            [{'unit_key' => {:name => 'zsh'}, :type_id => 'rpm'}])
      assert_equal 202, response.code
      refute_empty response
    end
  end
end
