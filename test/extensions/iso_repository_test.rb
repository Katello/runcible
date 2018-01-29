require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'
require './lib/runcible'

module Extensions
  module TestIsoRepositoryBase
    def setup
      @support = RepositorySupport.new('iso')
      @extension = TestRuncible.server.extensions.repository
    end
  end

  class TestIsoRepositoryCreate < MiniTest::Unit::TestCase
    include TestIsoRepositoryBase

    def setup
      super
      @repo_url = "file://#{RepositorySupport::FIXTURE_PATH}/iso"
      @repo_id = RepositorySupport.repo_id
    end

    def teardown
      @support.destroy_repo(@repo_id)
      super
    end

    def test_create_with_importer_and_distributors_objects
      distributors = [Runcible::Models::IsoDistributor.new('path', true, true, :id => 'iso_distributor')]
      importer = Runcible::Models::IsoImporter.new(:feed => @repo_url)

      response = @extension.create_with_importer_and_distributors(@repo_id, importer, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(@repo_id, :details => true)
      assert_equal @repo_id, response['id']
      assert_equal 'iso_importer', response['importers'].first['importer_type_id']
    end

    def test_sync
      @support.create_repo(:importer => true)
      response = @support.sync_repo
      assert_async_response(response)
    end

    def test_file_ids
      @support.create_and_sync_repo(:importer => true)
      response = @extension.file_ids(RepositorySupport.repo_id)
      refute_empty response
    end

    def test_files
      @support.create_and_sync_repo(:importer => true)
      response = @extension.files(RepositorySupport.repo_id)
      refute_empty response
    end
  end
end
