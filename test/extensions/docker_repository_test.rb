require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'
require './lib/runcible'

module Extensions
  module TestDockerRepositoryBase
    def setup
      @support = RepositorySupport.new('docker')
      @extension = TestRuncible.server.extensions.repository
    end
  end

  class TestDockerRepositoryCreate < MiniTest::Unit::TestCase
    include TestDockerRepositoryBase

    def teardown
      @support.destroy_repo
      super
    end

    def test_create_with_importer
      response = @extension.create_with_importer(RepositorySupport.repo_id, :id => 'docker_importer')
      assert_equal 201, response.code
      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'docker_importer', response['importers'].first['importer_type_id']
    end

    def test_create_with_importer_object
      mock_importer = Runcible::Models::DockerImporter.new(:feed => 'https://index.docker.io',
                                                           :upstream_name => 'busybox')
      response = @extension.create_with_importer(RepositorySupport.repo_id, mock_importer)
      assert_equal 201, response.code
      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'docker_importer', response['importers'].first['importer_type_id']

      @extension.expects(:create).with(RepositorySupport.repo_id, has_entry(:notes, anything)).returns(true)
      @extension.create_with_importer(RepositorySupport.repo_id, Runcible::Models::DockerImporter.new)
    end

    def test_create_with_distributors
      distributors = [{'type_id' => 'docker_distributor_web', 'id' => '123', 'auto_publish' => true,
                       'config' => {'docker_publish_directory' => '/path'}}]
      response = @extension.create_with_distributors(RepositorySupport.repo_id, distributors)

      assert_equal 201, response.code
      assert_equal RepositorySupport.repo_id, response['id']
    end

    def test_create_with_distributor_object
      repo_id = RepositorySupport.repo_id + '_distro'
      url = "http://acme.org"
      repo_registry_id = "busybox"
      mock_distro = Runcible::Models::DockerDistributor.new(:docker_publish_directory => '/path',
                                                            :id => '123',
                                                            :redirect_url => url,
                                                            :repo_registry_id => repo_registry_id)
      response = @extension.create_with_distributors(repo_id, [mock_distro])
      assert_equal 201, response.code
      response = @extension.retrieve(repo_id, :details => true)
      assert_equal repo_id, response['id']
      assert_equal 'docker_distributor_web', response['distributors'].first['distributor_type_id']
      assert_equal url, response['distributors'].first['config']["redirect_url"]
      assert_equal repo_registry_id, response['distributors'].first['config']["repo-registry-id"]
    ensure
      @support.destroy_repo(repo_id)
    end

    def test_create_with_importer_and_distributors
      distributors = [{'type_id' => 'docker_distributor_web', 'id' => '123', 'auto_publish' => true,
                       'config' => {}}]
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id,
                                                                 {:id => 'docker_importer'}, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'docker_distributor_web', response['distributors'].first['distributor_type_id']
    end

    def test_create_with_importer_and_distributors_objects
      distributors = [Runcible::Models::DockerDistributor.new(:id => '123')]
      importer = Runcible::Models::DockerImporter.new
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id, importer, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'docker_importer', response['importers'].first['importer_type_id']
    end

    def test_docker_blob
      assert_equal 'docker_blob', Runcible::Extensions::DockerBlob.content_type
    end
  end
end
