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
  include RepositorySupport

  def setup
    @resource = Runcible::Resources::Task
    VCR.insert_cassette('task', :match_requests_on => [:method, :path, :body])
  end

  def teardown
    VCR.eject_cassette
  end

end


class TestResourcesTask < MiniTest::Unit::TestCase
  include TestResourcesTaskBase

  def self.before_suite
    RepositorySupport.create_repo(:importer => true)
    @@task = RepositorySupport.sync_repo
  end

  def self.after_suite
    RepositorySupport.destroy_repo
  end

  def test_path
    path = @resource.path
    assert_match("tasks/", path)
  end

  def test_path_with_task_id
    path = @resource.path(@@task['task_id'])
    assert_match("tasks/#{@@task['task_id']}/", path)
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
    response = @resource.cancel(RepositorySupport.task['task_id'])

    assert_equal 200, response.code
  end

  def test_poll_all
    tasks = @resource.poll_all([RepositorySupport.task['task_id']])
    
    refute_empty tasks
    refute_empty tasks.select{ |task| task['task_id'] == RepositorySupport.task['task_id'] }
  end

end
