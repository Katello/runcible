require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'
require './lib/runcible'

module Extensions
  module TestPythonRepositoryBase
    def setup
      @support = RepositorySupport.new('python')
      @extension = TestRuncible.server.extensions.repository
    end
  end

  class TestPythonRepositoryCreate < MiniTest::Unit::TestCase
    include TestPythonRepositoryBase

    def teardown
      @support.destroy_repo
      super
    end

    def test_create_with_importer
      response = @extension.create_with_importer(
        RepositorySupport.repo_id,
        :id => 'python_importer',
        :packages_names => ['django']
      )
      assert_equal 201, response.code
      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'python_importer', response['importers'].first['importer_type_id']
    end

    def test_create_with_importer_object
      mock_importer = Runcible::Models::PythonImporter.new(
        :feed => 'https://pypi.python.org/pypi',
        :packages_names => ['django']
      )
      response = @extension.create_with_importer(RepositorySupport.repo_id, mock_importer)
      assert_equal 201, response.code
      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'python_importer', response['importers'].first['importer_type_id']

      @extension.expects(:create).with(RepositorySupport.repo_id, has_entry(:notes, anything)).returns(true)
      @extension.create_with_importer(RepositorySupport.repo_id, Runcible::Models::PythonImporter.new)
    end

    def test_create_with_distributors
      distributors = [{'type_id' => 'python_distributor', 'auto_publish' => true,
                       'config' => {'publish_dir' => '/path'}}]
      response = @extension.create_with_distributors(RepositorySupport.repo_id, distributors)

      assert_equal 201, response.code
      assert_equal RepositorySupport.repo_id, response['id']
    end

    def test_create_with_distributor_object
      repo_id = RepositorySupport.repo_id + '_distro'
      distributor = Runcible::Models::PythonDistributor.new(:id => '123')
      response = @extension.create_with_distributors(repo_id, [distributor])
      assert_equal 201, response.code
      response = @extension.retrieve(repo_id, :details => true)

      assert_equal repo_id, response['id']
      assert_equal 'python_distributor', response['distributors'].first['distributor_type_id']
    ensure
      @support.destroy_repo(repo_id)
    end

    def test_create_with_importer_and_distributors
      distributors = [{'type_id' => 'python_distributor', 'auto_publish' => true,
                       'config' => {'publish_dir' => '/path'}}]
      response = @extension.create_with_importer_and_distributors(
        RepositorySupport.repo_id,
        {:id => 'python_importer', :packages_names => ['django']},
        distributors
      )
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'python_distributor', response['distributors'].first['distributor_type_id']
    end

    def test_create_with_importer_and_distributors_objects
      distributors = [Runcible::Models::PythonDistributor.new(:id => '123')]
      importer = Runcible::Models::PythonImporter.new
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id, importer, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'python_importer', response['importers'].first['importer_type_id']
    end
  end

  class TestPythonRepositorySync < MiniTest::Unit::TestCase
    include TestPythonRepositoryBase

    def setup
      super
    end

    def teardown
      @support.destroy_repo
    ensure
      super
    end

    def test_sync_repo_with_python_importer
      @support.create_repo(:importer => true, :importer_config => {:package_names => 'django'})
      response = @extension.sync(RepositorySupport.repo_id)

      tasks = assert_async_response(response)
      assert_includes tasks.first['tags'], 'pulp:action:sync'

      response = @extension.unit_search(RepositorySupport.repo_id, {})
      refute_empty response
    end
  end
end
