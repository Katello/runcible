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


module TestResourcesScheduleBase

  def setup
    @resource = TestRuncible.server.resources.repository_schedule
    @support = RepositorySupport.new
    VCR.insert_cassette(self.class.cassette_name)
  end

  def teardown
    VCR.eject_cassette
  end

end

class TestResourcesRepositoryCreateSchedule < MiniTest::Unit::TestCase
  include TestResourcesScheduleBase

  def setup
    super
    @support.create_repo :importer=>true
    @support.create_schedule
  end

  def teardown
    @support.destroy_repo
    super
  end

  def test_repository_schedules_path
    path = @resource.class.path('foo', 'some_importer')

    assert_match "repositories/foo/importers/some_importer/schedules/sync/", path
  end

  def test_schedule_create
    response = @resource.create(RepositorySupport.repo_id, 'yum_importer', "2012-09-25T20:44:00Z/P7D")

    assert_equal 201, response.code
  end

  def test_list_schedules
    list = @resource.list(RepositorySupport.repo_id, 'yum_importer')

    assert_match list.first[:schedule], @support.schedule_time
  end

end

class TestResourcesScheduleUpdate < MiniTest::Unit::TestCase
  include TestResourcesScheduleBase

  def setup
    super
    @support.create_repo :importer=>true
    @support.create_schedule
  end

  def teardown
    @support.destroy_repo
    super
  end

  def test_update_schedule
    id = @resource.list(RepositorySupport.repo_id, 'yum_importer').first['_id']
    response = @resource.update(RepositorySupport.repo_id, 'yum_importer', id, {:schedule=>'P1DT'})

    assert_equal 200, response.code
  end
end


class TestResourcesScheduleDelete < MiniTest::Unit::TestCase
  include TestResourcesScheduleBase

  def setup
    super
    @support.create_repo :importer=>true
    @support.create_schedule
  end

  def teardown
    @support.destroy_repo
    super
  end

  def test_delete_schedules
    id = @resource.list(RepositorySupport.repo_id, 'yum_importer').first['_id']
    response = @resource.delete(RepositorySupport.repo_id, 'yum_importer', id)

    assert_equal 200, response.code
  end

end
