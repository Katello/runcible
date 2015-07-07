require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'
require './lib/runcible/resources/event_notifier'

module Resources
  module TestEventNotifierBase
    def setup
      @resource = TestRuncible.server.resources.event_notifier
      @resource_class = Runcible::Resources::EventNotifier
    end
  end

  class TestEventNotifier < MiniTest::Unit::TestCase
    include TestEventNotifierBase

    def setup
      super
      @@notifier_id = nil
    end

    def teardown
      @resource.delete(@@notifier_id) if @@notifier_id
    end

    def test_create
      response = @resource.create(@resource_class::NotifierTypes::REST_API, {:url => 'http://foo.com/foo/'},
              [@resource_class::EventTypes::REPO_PUBLISH_COMPLETE])
      @@notifier_id = response['id']

      assert_equal 201, response.code
    end
  end

  class TestEventNotifierList < MiniTest::Unit::TestCase
    include TestEventNotifierBase

    def setup
      super
      response = @resource.create(@resource.class::NotifierTypes::REST_API, {:url => 'http://foo.com/foo/'},
              [@resource_class::EventTypes::REPO_PUBLISH_COMPLETE])
      @@notifier_id = response['id']
    end

    def teardown
      @resource.delete(@@notifier_id)
    end

    def test_list
      response = @resource.list

      assert_equal 200, response.code
      refute_empty response
    end
  end

  class TestEventNotifierDelete < MiniTest::Unit::TestCase
    include TestEventNotifierBase

    def setup
      super
      response = @resource.create(@resource.class::NotifierTypes::REST_API, {:url => 'http://foo.com/foo/'},
              [@resource_class::EventTypes::REPO_PUBLISH_COMPLETE])
      @@notifier_id = response['id']
    end

    def test_remove
      response = @resource.delete(@@notifier_id)

      assert_equal 200, response.code
    end
  end
end
