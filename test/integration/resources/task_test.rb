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
    assert response.code == 200
    assert response['task_id'] == @@task['task_id']
  end

  def test_list
    response = @resource.list
    assert response.code == 200
    assert response.length > 0
    #assert response.first['task_id'] == RepositorySupport.task['task_id']
  end

=begin
  #TODO: Needs more reliable testable scenario - scheduled sync in the future?
  def test_cancel
    response = @resource.cancel(RepositorySupport.task['task_id'])
    assert response.code == 200
  end
=end

end
