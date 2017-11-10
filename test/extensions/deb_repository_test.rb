require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'
require './lib/runcible'

module Extensions
  module TestDebRepositoryBase
    def setup
      @support = RepositorySupport.new('deb')
      @extension = TestRuncible.server.extensions.repository
    end
  end

  class TestDebRepositoryCreate < MiniTest::Unit::TestCase
    include TestDebRepositoryBase

    def teardown
      @support.destroy_repo
      super
    end

    def test_create_with_importer
      response = @extension.create_with_importer(RepositorySupport.repo_id, :id => 'deb_importer')
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'deb_importer', response['importers'].first['importer_type_id']
    end

    def test_create_with_importer_object
      response = @extension.create_with_importer(RepositorySupport.repo_id, Runcible::Models::DebImporter.new)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'deb_importer', response['importers'].first['importer_type_id']

      @extension.expects(:create).with(RepositorySupport.repo_id, has_entry(:notes, anything)).returns(true)
      @extension.create_with_importer(RepositorySupport.repo_id, Runcible::Models::DebImporter.new)
    end

    def test_create_with_distributors
      distributors = [{'type_id' => 'deb_distributor', 'id' => '123', 'auto_publish' => true,
                       'config' => {'relative_url' => '/path', 'http' => true, 'https' => true}}]
      response = @extension.create_with_distributors(RepositorySupport.repo_id, distributors)

      assert_equal 201, response.code
      assert_equal RepositorySupport.repo_id, response['id']
    end

    def test_create_with_distributor_object
      repo_id = RepositorySupport.repo_id + '_distro'
      response = @extension.create_with_distributors(repo_id, [Runcible::Models::DebDistributor.new(
        '/path', true, true, :id => '123')])
      assert_equal 201, response.code

      response = @extension.retrieve(repo_id, :details => true)
      assert_equal repo_id, response['id']
      assert_equal 'deb_distributor', response['distributors'].first['distributor_type_id']
    ensure
      @support.destroy_repo(repo_id)
    end

    def test_create_with_importer_and_distributors
      distributors = [{'type_id' => 'deb_distributor', 'id' => '234', 'auto_publish' => true,
                       'config' => {'relative_url' => '/path', 'http' => true, 'https' => true}}]
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id,
                                                                 {:id => 'deb_importer'}, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'deb_distributor', response['distributors'].first['distributor_type_id']
    end

    def test_create_with_importer_and_distributors_objects
      distributors = [Runcible::Models::DebDistributor.new('/path', true, true, :id => '123')]
      importer = Runcible::Models::DebImporter.new
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id, importer, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'deb_importer', response['importers'].first['importer_type_id']
    end
  end
end
