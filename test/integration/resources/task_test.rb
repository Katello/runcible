# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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
    RepositorySupport.sync_repo
  end

  def self.after_suite
    RepositorySupport.destroy_repo
  end

  def test_path
    path = @resource.path
    assert_match("tasks/", path)
  end

  def test_path_with_task_id
    path = @resource.path(RepositorySupport.task['task_id'])
    assert_match("tasks/#{RepositorySupport.task['task_id']}/", path)
  end

  def test_poll
    response = @resource.poll(RepositorySupport.task['task_id'])
    assert response.code == 200
    assert response['task_id'] == RepositorySupport.task['task_id']
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
