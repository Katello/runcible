require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'

module Resources
  module TestScheduleBase
    def setup
      @resource = TestRuncible.server.resources.repository_schedule
      @support = RepositorySupport.new
    end
  end

  class TestRepositoryCreateSchedule < MiniTest::Unit::TestCase
    include TestScheduleBase

    def setup
      super
      @support.create_repo :importer => true
      @support.create_schedule
    end

    def teardown
      @support.destroy_repo
      super
    end

    def test_repository_schedules_path
      path = @resource.class.path('foo', 'some_importer')

      assert_match 'repositories/foo/importers/some_importer/schedules/sync/', path
    end

    def test_schedule_create
      response = @resource.create(RepositorySupport.repo_id, 'yum_importer', '2012-09-25T20:44:00Z/P7D')

      assert_equal 201, response.code
    end

    def test_list_schedules
      list = @resource.list(RepositorySupport.repo_id, 'yum_importer')

      assert_match list.first[:schedule], @support.schedule_time
    end
  end

  class TestScheduleUpdate < MiniTest::Unit::TestCase
    include TestScheduleBase

    def setup
      super
      @support.create_repo :importer => true
      @support.create_schedule
    end

    def teardown
      @support.destroy_repo
      super
    end

    def test_update_schedule
      id = @resource.list(RepositorySupport.repo_id, 'yum_importer').first['_id']
      response = @resource.update(RepositorySupport.repo_id, 'yum_importer', id, :schedule => 'P1DT')

      assert_equal 200, response.code
    end
  end

  class TestScheduleDelete < MiniTest::Unit::TestCase
    include TestScheduleBase

    def setup
      super
      @support.create_repo :importer => true
      @support.create_schedule
    end

    def teardown
      @support.destroy_repo
      super
    end

    def test_delete_schedules
      id = @resource.list(RepositorySupport.repo_id, 'yum_importer').first['_id']
      response = @resource.delete(RepositorySupport.repo_id, 'yum_importer', id)

      assert_equal 200, response.code
    end
  end
end
