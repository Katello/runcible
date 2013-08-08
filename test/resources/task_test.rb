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
require './lib/runcible/resources/task'


module TestResourcesTaskBase

  def setup
    @resource = TestRuncible.server.resources.task
    VCR.insert_cassette('task', :match_requests_on => [:method, :path, :body], :allow_playback_repeats => true)
  end

  def teardown
    VCR.eject_cassette
  end

end


class TestResourcesTask < MiniTest::Unit::TestCase
  include TestResourcesTaskBase

  def self.before_suite
    @@support = RepositorySupport.new
    @@support.create_repo(:importer => true)
    @@task = @@support.sync_repo
  end

  def self.after_suite
    @@support.destroy_repo
  end

  def test_path
    path = @resource.class.path

    assert_match "tasks/", path
  end

  def test_path_with_task_id
    path = @resource.class.path(@@task['task_id'])

    assert_match "tasks/#{@@task['task_id']}/", path
  end

  def test_poll
    response = @resource.poll(@@task['task_id'])

    assert_equal 200, response.code
    assert_equal @@task['task_id'], response['task_id']
  end

  def test_list
    response = @resource.list

    assert_equal 200, response.code
    refute_empty response
  end

  def test_cancel
    skip "TODO: Needs more reliable testable scenario"
    response = @resource.cancel(@@support.task['task_id'])

    assert_equal 200, response.code
  end

  def test_poll_all
    tasks = @resource.poll_all([@@support.task['task_id']])
    
    refute_empty tasks
    refute_empty tasks.select{ |task| task['task_id'] == @@support.task['task_id'] }
  end

end
