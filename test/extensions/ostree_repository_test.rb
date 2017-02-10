require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'
require './lib/runcible'

module Extensions
  module TestOstreeRepositoryBase
    def setup
      @support = RepositorySupport.new('ostree')
      @extension = TestRuncible.server.extensions.repository
    end
  end

  class TestOstreeRepositoryCreate < MiniTest::Unit::TestCase
    include TestOstreeRepositoryBase

    def teardown
      @support.destroy_repo
      super
    end

    def test_create_with_importer
      response = @extension.create_with_importer(RepositorySupport.repo_id, :id => 'ostree_web_importer')
      assert_equal 201, response.code
      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'ostree_web_importer', response['importers'].first['importer_type_id']
    end

    def test_create_with_importer_object
      url = "http://cdn.qa.redhat.com/content/htb/rhel/server/7/x86_64/extras/ostree/"
      branches = ["redhat-atomic-host/el7.0/x86_64/base", "redhat-atomic-host/el7.0/x86_64/medium"]
      mock_importer = Runcible::Models::OstreeImporter.new(:feed => url,
                                                           :branches => branches)
      response = @extension.create_with_importer(RepositorySupport.repo_id, mock_importer)
      assert_equal 201, response.code
      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'ostree_web_importer', response['importers'].first['importer_type_id']

      @extension.expects(:create).with(RepositorySupport.repo_id, has_entry(:notes, anything)).returns(true)
      @extension.create_with_importer(RepositorySupport.repo_id, Runcible::Models::OstreeImporter.new)
    end

    def test_create_with_distributors
      distributors = [{'type_id' => 'ostree_web_distributor', 'id' => '123', 'auto_publish' => true,
                       'config' => {'ostree_publish_directory' => '/path'}}]
      response = @extension.create_with_distributors(RepositorySupport.repo_id, distributors)

      assert_equal 201, response.code
      assert_equal RepositorySupport.repo_id, response['id']
    end

    def test_create_with_distributor_object
      repo_id = "#{RepositorySupport.repo_id}_distro"
      ostree_publish_directory = "/path"
      relative_path = "/relative_path"
      mock_distro = Runcible::Models::OstreeDistributor.new(:ostree_publish_directory => ostree_publish_directory,
                                                            :id => '123',
                                                            :relative_path => relative_path)
      response = @extension.create_with_distributors(repo_id, [mock_distro])
      assert_equal 201, response.code
      response = @extension.retrieve(repo_id, :details => true)
      assert_equal repo_id, response['id']
      assert_equal 'ostree_web_distributor', response['distributors'].first['distributor_type_id']
      assert_equal relative_path, response['distributors'].first['config']["relative_path"]
      assert_equal ostree_publish_directory, response['distributors'].first['config']["ostree_publish_directory"]
    ensure
      @support.destroy_repo(repo_id)
    end

    def test_create_with_importer_and_distributors
      distributors = [{'type_id' => 'ostree_web_distributor', 'id' => '123', 'auto_publish' => true,
                       'config' => {}}]
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id,
                                                                 {:id => 'ostree_web_importer'}, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'ostree_web_distributor', response['distributors'].first['distributor_type_id']
    end

    def test_create_with_importer_and_distributors_objects
      distributors = [Runcible::Models::OstreeDistributor.new(:id => '123')]
      importer = Runcible::Models::OstreeImporter.new
      depth = -1
      importer.depth = depth
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id, importer, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'ostree_web_importer', response['importers'].first['importer_type_id']
      assert_equal depth, response['importers'].first['config']['depth']
    end
  end

  class TestOstreeBranchRepositoryUnitList < MiniTest::Unit::TestCase
    def self.before_suite
      @@extension = TestRuncible.server.extensions.repository
      self.support = RepositorySupport.new("ostree")
      self.support.destroy_repo
      self.support.create_and_sync_repo(:importer => true)
    end

    def self.after_suite
      self.support.destroy_repo
    end

    def test_ostree_branch_ids
      response = @@extension.ostree_branch_ids(RepositorySupport.repo_id)
      refute_empty response
      assert_kind_of String, response.first
    end

    def test_ostree_branches
      response = @@extension.ostree_branches(RepositorySupport.repo_id)
      refute_empty response
      assert_kind_of Hash, response.first
      assert_includes response.first.keys, "branch"
      assert_includes response.first.keys, "commit"
      assert_includes response.first.keys, "metadata"
      assert_includes response.first["metadata"].keys, "version"
    end
  end
end
