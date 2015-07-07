require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'
require './lib/runcible/resources/task'

module Resources
  module TestTaskBase
    def setup
      @resource = TestRuncible.server.resources.task
    end
  end

  class TestTask < MiniTest::Unit::TestCase
    include TestTaskBase
    def self.before_suite
      self.support = RepositorySupport.new
      self.support.create_repo(:importer => true)
      @@task_id = self.support.sync_repo['spawned_tasks'].first['task_id']
    end

    def self.after_suite
      self.support.destroy_repo
    end

    def test_path
      path = @resource.class.path

      assert_match 'tasks/', path
    end

    def test_path_with_task_id
      path = @resource.class.path(@@task_id)

      assert_match "tasks/#{@@task_id}/", path
    end

    def test_poll
      response = @resource.poll(@@task_id)

      assert_equal 200, response.code
      assert_equal @@task_id, response['task_id']
    end

    def test_list
      response = @resource.list

      assert_equal 200, response.code
      refute_empty response
    end

    def test_cancel
      skip 'TODO: Needs more reliable testable scenario'
      response = @resource.cancel(@@task_id)

      assert_equal 200, response.code
    end

    def test_poll_all
      tasks = @resource.poll_all([@@task_id])

      refute_empty tasks
      refute_empty tasks.select { |task| task['task_id'] == @@task_id }
    end
  end
end
