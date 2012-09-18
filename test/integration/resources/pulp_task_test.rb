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

require './test/integration/resources/helpers/repository_helper'
require './lib/runcible/resources/task'


module TestResourcesTaskBase
  include RepositoryHelper

  def setup
    @resource = Runcible::Resources::Task
    VCR.insert_cassette('pulp_task')
  end

  def teardown
    VCR.eject_cassette
  end

end


class TestResourcesTask < MiniTest::Unit::TestCase
  include TestResourcesTaskBase

  def setup
    super
    RepositoryHelper.create_repo(:importer => true)
    RepositoryHelper.sync_repo(false)
  end

  def teardown
    super
    RepositoryHelper.destroy_repo
  end

  def test_path
    path = @resource.path
    assert_match("tasks/", path)
  end

  def test_path_with_task_id
    path = @resource.path(RepositoryHelper.task['task_id'])
    assert_match("tasks/#{RepositoryHelper.task['task_id']}/", path)
  end

  def test_poll
    response = @resource.poll(RepositoryHelper.task['task_id'])
    assert response.code == 200
    assert response['task_id'] == RepositoryHelper.task['task_id']
  end

  def test_list
    response = @resource.list
    assert response.code == 200
    assert response.length > 0
    #assert response.first['task_id'] == RepositoryHelper.task['task_id']
  end

=begin
  #TODO: Needs more reliable testable scenario - scheduled sync in the future?
  def test_cancel
    response = @resource.cancel(RepositoryHelper.task['task_id'])
    assert response.code == 200
  end
=end

end
