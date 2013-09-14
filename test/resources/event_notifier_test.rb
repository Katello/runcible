
# Copyright 2012 Red Hat, Inc.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'rubygems'
require 'minitest/autorun'

require './test/support/repository_support'
require './lib/runcible/resources/event_notifier'

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
    VCR.insert_cassette('event_notifier')
    @@notifier_id = nil
  end

  def teardown
    @resource.delete(@@notifier_id) if @@notifier_id
  ensure
    VCR.eject_cassette
  end

  def test_create
    response = @resource.create(@resource_class::NotifierTypes::REST_API, {:url=>'http://foo.com/foo/'},
            [@resource_class::EventTypes::REPO_PUBLISH_COMPLETE])
    @@notifier_id = response['id']

    assert_equal 201, response.code
  end

end

class TestEventNotifierList < MiniTest::Unit::TestCase
  include TestEventNotifierBase

  def setup
    super
    VCR.insert_cassette('event_notifier_list')
    response = @resource.create(@resource.class::NotifierTypes::REST_API, {:url=>'http://foo.com/foo/'},
            [@resource_class::EventTypes::REPO_PUBLISH_COMPLETE])
    @@notifier_id = response['id']
  end

  def teardown
    response = @resource.delete(@@notifier_id)
    VCR.eject_cassette
  end

  def test_list
    response = @resource.list()

    assert_equal 200, response.code
    refute_empty response
  end

end

class TestEventNotifierDelete < MiniTest::Unit::TestCase
  include TestEventNotifierBase

  def setup
    super
    VCR.insert_cassette('event_notifier_remove')
    response = @resource.create(@resource.class::NotifierTypes::REST_API, {:url=>'http://foo.com/foo/'},
            [@resource_class::EventTypes::REPO_PUBLISH_COMPLETE])
    @@notifier_id = response['id']
  end

  def teardown
    VCR.eject_cassette
  end

  def test_remove
    response = @resource.delete(@@notifier_id)

    assert_equal 200, response.code
  end

end
