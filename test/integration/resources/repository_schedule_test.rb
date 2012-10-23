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
require './lib/runcible/resources/repository'
require './lib/runcible/resources/repository_schedule'
require './lib/runcible/extensions/repository'
require './lib/runcible/extensions/distributor'
require './lib/runcible/extensions/importer'
require './lib/runcible/extensions/yum_importer'


module TestResourcesScheduleBase
  include RepositoryHelper

  def setup
    @resource = Runcible::Resources::RepositorySchedule
  end

  def teardown
    VCR.eject_cassette
  end

end

class TestResourcesRepositoryCreateSchedule < MiniTest::Unit::TestCase
  include TestResourcesScheduleBase

  def setup
    super
    VCR.insert_cassette('repository_schedules')
    RepositoryHelper.create_repo :importer=>true
    RepositoryHelper.create_schedule
  end

  def teardown
    RepositoryHelper.destroy_repo
    super
  end


  def test_repository_schedules_path
    path = @resource.path('foo', 'some_importer')
    assert_match("repositories/foo/importers/some_importer/schedules/sync/", path)
  end

  def test_schedule_create
    response = @resource.create(RepositoryHelper.repo_id, 'yum_importer', "2012-09-25T20:44:00Z/P7D")
    assert response.code == 201
  end


  def test_list_schedules
    list = @resource.list(RepositoryHelper.repo_id, 'yum_importer')
    assert_match(list.first[:schedule], RepositoryHelper.schedule_time)
  end

end

class TestResourcesScheduleUpdate < MiniTest::Unit::TestCase
  include TestResourcesScheduleBase

  def setup
    super
    VCR.insert_cassette('repository_schedules_update')
    RepositoryHelper.create_repo :importer=>true
    RepositoryHelper.create_schedule
  end

  def teardown
    RepositoryHelper.destroy_repo
    super
  end

  def test_update_schedule
    id = @resource.list(RepositoryHelper.repo_id, 'yum_importer').first['_id']
    response = @resource.update(RepositoryHelper.repo_id, 'yum_importer', id, {:schedule=>'P1DT'})
    assert response.code == 200
  end
end


class TestResourcesScheduleDelete < MiniTest::Unit::TestCase
  include TestResourcesScheduleBase

  def setup
    super
    VCR.insert_cassette('repository_schedules_delete')
    RepositoryHelper.create_repo :importer=>true
    RepositoryHelper.create_schedule
  end

  def teardown
    RepositoryHelper.destroy_repo
    super
  end

  def test_delete_schedules
    id = @resource.list(RepositoryHelper.repo_id, 'yum_importer').first['_id']
    response = @resource.delete(RepositoryHelper.repo_id, 'yum_importer', id)
    assert response.code == 200
  end

end