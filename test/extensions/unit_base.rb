require 'rubygems'
require 'minitest/autorun'
require 'minitest/mock'
require './lib/runcible'
require './test/support/repository_support'

module Extensions
  class UnitCopyBase < MiniTest::Unit::TestCase
    def self.clone_name
      RepositorySupport.repo_id + '_clone'
    end

    def self.before_suite
      self.support = RepositorySupport.new
      if respond_to?(:extension_class)
        self.support.destroy_repo(clone_name)
        self.support.destroy_repo
        self.support.create_and_sync_repo(:importer => true)
        TestRuncible.server.extensions.repository.create_with_importer(clone_name, :id => 'yum_importer')
      end
    end

    def self.after_suite
      if respond_to?(:extension_class)
        self.support.destroy_repo(clone_name)
        self.support.destroy_repo
      end
    end

    def units(repo)
      TestRuncible.server.extensions.repository.unit_search(repo,
      :type_ids => [self.class.extension_class.class.content_type])
    end

    def unit_ids(repo)
      units(repo).map { |i| i['unit_id'] }
    end
  end

  class UnitUnassociateBase < MiniTest::Unit::TestCase
    def self.clone_name
      RepositorySupport.repo_id + '_clone'
    end

    def self.before_suite
      self.support = RepositorySupport.new
      if respond_to?(:extension_class)
        self.support.create_and_sync_repo(:importer => true)
        TestRuncible.server.extensions.repository.create_with_importer(clone_name, :id => 'yum_importer')
      end
    end

    def self.after_suite
      if respond_to?(:extension_class)
        self.support.destroy_repo(clone_name)
        self.support.destroy_repo
      end
    end

    def content_ids(repo)
      groups = units(repo)
      groups.map { |i| i['metadata']['id'] }
    end

    def units(repo)
      TestRuncible.server.extensions.repository.unit_search(repo,
      :type_ids => [self.class.extension_class.content_type])
    end

    def unit_ids(repo)
      units(repo).map { |i| i['unit_id'] }
    end
  end
end
