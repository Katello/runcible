require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'
require './lib/runcible'

module Extensions
  module TestPuppetRepositoryBase
    def setup
      @support = RepositorySupport.new('puppet')
      @extension = TestRuncible.server.extensions.repository
    end
  end

  class TestPuppetRepositoryCreate < MiniTest::Unit::TestCase
    include TestPuppetRepositoryBase

    def teardown
      @support.destroy_repo
      super
    end

    def test_create_with_importer
      response = @extension.create_with_importer(RepositorySupport.repo_id, :id => 'puppet_importer')
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'puppet_importer', response['importers'].first['importer_type_id']
    end

    def test_create_with_importer_object
      response = @extension.create_with_importer(RepositorySupport.repo_id, Runcible::Models::PuppetImporter.new)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'puppet_importer', response['importers'].first['importer_type_id']

      @extension.expects(:create).with(RepositorySupport.repo_id, has_entry(:notes, anything)).returns(true)
      @extension.create_with_importer(RepositorySupport.repo_id, Runcible::Models::PuppetImporter.new)
    end

    def test_create_with_distributors
      distributors = [{'type_id' => 'puppet_distributor', 'id' => '123', 'auto_publish' => true,
                       'config' => {'relative_url' => '/path', 'http' => true, 'https' => true}}]
      response = @extension.create_with_distributors(RepositorySupport.repo_id, distributors)

      assert_equal 201, response.code
      assert_equal RepositorySupport.repo_id, response['id']
    end

    def test_create_with_distributor_object
      repo_id = RepositorySupport.repo_id + '_distro'
      response = @extension.create_with_distributors(repo_id, [Runcible::Models::PuppetDistributor.new(
        '/path', true, true, :id => '123')])
      assert_equal 201, response.code

      response = @extension.retrieve(repo_id, :details => true)
      assert_equal repo_id, response['id']
      assert_equal 'puppet_distributor', response['distributors'].first['distributor_type_id']
    ensure
      @support.destroy_repo(repo_id)
    end

    def test_create_with_importer_and_distributors
      distributors = [{'type_id' => 'puppet_distributor', 'id' => '123', 'auto_publish' => true,
                       'config' => {'relative_url' => '/', 'http' => true, 'https' => true}}]
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id,
                                                                 {:id => 'puppet_importer'}, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'puppet_distributor', response['distributors'].first['distributor_type_id']
    end

    def test_create_with_importer_and_distributors_objects
      distributors = [Runcible::Models::PuppetDistributor.new('/path', true, true, :id => '123')]
      importer = Runcible::Models::PuppetImporter.new
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id, importer, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'puppet_importer', response['importers'].first['importer_type_id']
    end
  end
end
