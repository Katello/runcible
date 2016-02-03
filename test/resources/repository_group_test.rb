require 'rubygems'
require 'minitest/autorun'
require './lib/runcible/resources/repository_group'
require './lib/runcible/resources/repository'
require './test/support/repository_support'

module Resources
  module TestRepoGroupBase
    def setup
      @support = RepositorySupport.new
      @resource = TestRuncible.server.resources.repository_group
      @repo_group_id = 'integration_test_repository_group'
    end

    def create_repo_group(options = {})
      if options[:with_distributor]
        @resource.create(@repo_group_id, :display_name => 'foo_w_distributor', :description => 'Test description.',
                                         :distributors => [Runcible::Models::GroupExportDistributor.new(false, false)])
      else
        @resource.create(@repo_group_id, :display_name => 'foo', :description => 'Test description.')
      end
    rescue => e
      puts "could not create repo group with id => #{@repo_group_id}. Exception => #{e}"
    end

    def destroy_repo_group
      @resource.delete(@repo_group_id)
    rescue => e
      puts "could not destroy repo group with id => #{@repo_group_id}. Exception => #{e}"
    end
  end

  class TestRepoGroupCreate < MiniTest::Unit::TestCase
    include TestRepoGroupBase

    def teardown
      destroy_repo_group
      super
    end

    def test_create
      response = create_repo_group
      assert_equal @repo_group_id, response['id']
    end
  end

  class TestRepoGroup < MiniTest::Unit::TestCase
    include TestRepoGroupBase

    def teardown
      destroy_repo_group
      super
    end

    def setup
      super
      create_repo_group
    end

    def test_retrieve
      response = @resource.retrieve(@repo_group_id)
      assert_equal @repo_group_id, response['id']
    end

    def test_retrieve_all
      response = @resource.retrieve_all
      refute_empty response
      assert_equal 1, response.select { |grp| grp[:id] == @repo_group_id }.size
    end
  end

  class TestRepoGroupDestroy < MiniTest::Unit::TestCase
    include TestRepoGroupBase

    def setup
      super
      create_repo_group
    end

    def test_destroy
      response = @resource.delete(@repo_group_id)
      assert_equal 200, response.code
    end
  end

  class TestRepoGroupAssociate < MiniTest::Unit::TestCase
    include TestRepoGroupBase

    def setup
      super
      create_repo_group
      @support.create_repo
      @repo_id = RepositorySupport.repo_id
    end

    def teardown
      destroy_repo_group
      @support.destroy_repo
      super
    end

    def test_associate
      @criteria = {:criteria =>
                     {:filters =>
                       {:id =>
                          {'$in' => [@repo_id]}
                       }
                     }
                  }
      response = @resource.associate(@repo_group_id, @criteria)

      assert_equal 200, response.code
      assert_includes response, @repo_id
    end
  end

  class TestRepoGroupUnassociate < MiniTest::Unit::TestCase
    include TestRepoGroupBase

    def setup
      super
      create_repo_group
      @support.create_repo
      @repo_id = RepositorySupport.repo_id
      @criteria = {:criteria =>
                     {:filters =>
                       {:id =>
                          {'$in' => [@repo_id]}
                       }
                     }
                  }
      @resource.associate(@repo_group_id, @criteria)
    end

    def teardown
      destroy_repo_group
      @support.destroy_repo
      super
    end

    def test_unassociate
      response = @resource.unassociate(@repo_group_id, @criteria)

      assert_equal 200, response.code
      refute_includes response, @repo_id
    end
  end

  class TestRepoGroupRetrieveDistributorsAndPublish < MiniTest::Unit::TestCase
    include TestRepoGroupBase

    def setup
      super
      # the runcible repo group distributor uses a random ID when POSTing, we
      # need to be more lenient on VCR matches for test_publish to work.
      VCR.eject_cassette
      VCR.insert_cassette('resources/repo_group_retrieve_distributors_and_publish',
                          :match_requests_on => [:path, :method])

      create_repo_group(:with_distributor => true)
      @support.create_repo
      @repo_id = RepositorySupport.repo_id
    end

    def teardown
      destroy_repo_group
      @support.destroy_repo
      super
    end

    def test_retrieve_distributors
      response = @resource.retrieve_distributors @repo_group_id
      assert_equal 200, response.code
      assert_equal response.first['distributor_type_id'], 'group_export_distributor'
    end

    def test_publish
      distributors = @resource.retrieve_distributors @repo_group_id
      response = @resource.publish @repo_group_id, distributors.first["id"]
      assert_equal 202, response.code
    end
  end

  class TestRepoGroupRetrieveDistributorsEmpty < MiniTest::Unit::TestCase
    include TestRepoGroupBase

    def setup
      super
      create_repo_group
      @support.create_repo
      @repo_id = RepositorySupport.repo_id
    end

    def teardown
      destroy_repo_group
      @support.destroy_repo
      super
    end

    def test_retrieve_distributors_empty
      response = @resource.retrieve_distributors @repo_group_id
      assert_equal 200, response.code
      assert_equal response, []
    end
  end
end
