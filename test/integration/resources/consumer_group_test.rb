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
require './lib/runcible/resources/consumer_group'
#require 'test/integration/resources/supports/consumer_support'
require './test/support/repository_support'


module TestConsumerGroupBase
  include RepositorySupport

  def setup
    @resource = Runcible::Resources::ConsumerGroup
    @consumer_group_id = "integration_test_consumer_group"
    VCR.insert_cassette('consumer_group')
  end

  def teardown
    VCR.eject_cassette
  end

  def create_consumer_group
    @resource.create(@consumer_group_id, :display_name => "foo", :description => 'Test description.', :consumer_ids => [])
  rescue Exception => e
    puts e
  end

  def destroy_consumer_group
    @resource.delete(@consumer_group_id)
  rescue Exception => e
    puts e
  end

end


class TestConsumerGroupCreate < MiniTest::Unit::TestCase
  include TestConsumerGroupBase

  def teardown
    destroy_consumer_group
    super
  end

  def test_create
    response = create_consumer_group
    assert response['id'] == @consumer_group_id
  end
end


class TestConsumerGroupDestroy < MiniTest::Unit::TestCase
  include TestConsumerGroupBase

  def setup
    super
    create_consumer_group
  end

  def test_destroy
    response = @resource.delete(@consumer_group_id)
    assert_equal(200, response.code)
  end

end


class TestConsumerGroup < MiniTest::Unit::TestCase
  include TestConsumerGroupBase

  def setup
    super
    create_consumer_group
  end

  def teardown
    destroy_consumer_group
    super
  end

  def test_path
    path = @resource.path
    assert_match('consumer_groups/', path)
  end

  def test_path_with_id
    path = @resource.path(@consumer_group_id)
    assert_match("consumer_groups/#{@consumer_group_id}/", path)
  end

  def test_retrieve
    response = @resource.retrieve(@consumer_group_id)
    assert response.length > 0
    assert response['id'] == @consumer_group_id
    assert response['consumer_ids'] == []
  end

end

