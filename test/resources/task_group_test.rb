require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'
require './test/support/consumer_support'
require './lib/runcible/resources/task_group'

module Resources
  module TestTaskGroupBase
    def setup
      @consumer_support = ConsumerSupport.new
      @resource = TestRuncible.server.resources.task_group
      @repo_resource = TestRuncible.server.resources.repository

      @criteria = {
        'parallel' => true,
        'repo_criteria' => { 'filters' => { 'id' => { '$in' => [RepositorySupport.repo_id] } } }
      }
      @response = @repo_resource.regenerate_applicability(@criteria)
      @group_id = @response["group_id"]
    end
  end

  class TestTaskGroup < MiniTest::Unit::TestCase
    include TestTaskGroupBase
    def self.before_suite
      self.support = RepositorySupport.new
      self.support.create_and_sync_repo(:importer_and_distributor => true)
    end

    def self.after_suite
      self.support.destroy_repo
    end

    def test_path
      path = @resource.class.path
      assert_match 'task_groups/', path
    end

    def test_path_with_task_id
      path = @resource.class.path(@group_id)
      assert_match "task_groups/#{@group_id}/", path
    end

    def test_summary_path_with_task_id
      path = @resource.class.summary_path(@group_id)
      assert_match "task_groups/#{@group_id}/state_summary/", path
    end

    def test_summary
      response = @resource.summary(@group_id)
      assert_equal 200, response.code
      keys = ["accepted", "finished", "running", "canceled", "waiting", "skipped", "suspended", "error", "total"]
      assert_equal [], keys - response.keys
      assert keys.all? { |key| response[key].is_a? Numeric }
    end

    def test_completed
      task_group = Runcible::Resources::TaskGroup.new
      test1 = {"finished" => 10, "canceled" => 2, "skipped" => 4, "suspended" => 3, "error" => 1, "total" => 20}
      assert task_group.completed?(test1)
      test1["finished"] -= 1
      refute task_group.completed?(test1)
    end
  end

  class TestTaskGroupCancel < TestTaskGroup
    def teardown
      @consumer_support.destroy_consumer
    end

    def test_cancel
      #cancelling an empty task group results in a 404, so set it up so there is something in it
      @consumer_support.create_consumer(true)

      tasks = TestRuncible.server.resources.consumer.bind(ConsumerSupport.consumer_id, RepositorySupport.repo_id,
                                                  self.class.support.distributor['id'], :notify_agent => false)
      self.class.support.wait_on_response(tasks)
      tasks = TestRuncible.server.resources.consumer.regenerate_applicability_by_id(ConsumerSupport.consumer_id)
      self.class.support.wait_on_response(tasks)

      group_id = @repo_resource.regenerate_applicability(@criteria)['group_id']

      response = @resource.cancel(group_id)
      assert_equal 200, response.code
    end
  end
end
