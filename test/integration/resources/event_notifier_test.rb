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

require './lib/runcible/resources/event_notifier'




class TestEventNotifier < MiniTest::Unit::TestCase

  def setup
    VCR.insert_cassette('event_notifier')
    @resource = Runcible::Resources::EventNotifier
    @@notifier_id = nil
  end

  def teardown
    @resource.delete(@@notifier_id) if @@notifier_id
    VCR.eject_cassette
  end

  def test_create
    response = @resource.create(@resource::NotifierTypes::REST_API, {:url=>'http://foo.com/foo/'},
            [@resource::EventTypes::REPO_PUBLISH_COMPLETE])
    @@notifier_id = response['id']
    assert response.code == 201
  end

  def test_list
    response = @resource.list()
    assert response.code == 200
  end

end



class TestEventNotifierDelete < MiniTest::Unit::TestCase

  def setup
    VCR.insert_cassette('event_notifier_remove')
    @resource = Runcible::Resources::EventNotifier
    response = @resource.create(@resource::NotifierTypes::REST_API, {:url=>'http://foo.com/foo/'},
            [@resource::EventTypes::REPO_PUBLISH_COMPLETE])
    @@notifier_id = response['id']
  end

  def teardown
    VCR.eject_cassette
  end


  def test_remove
    response = @resource.delete(@@notifier_id)
    assert response.code == 200
    assert ! @resource.list.collect{|i| i[:id]}.include?(@@notifier_id)
  end



end


