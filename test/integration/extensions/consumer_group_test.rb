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
require './lib/runcible/extensions/consumer_group'
require './test/support/consumer_support'
require './test/support/consumer_group_support'
require './test/support/repository_support'


class TestConsumerGroup < MiniTest::Unit::TestCase

  def setup
    @resource = Runcible::Resources::ConsumerGroup
    @extension = Runcible::Extensions::ConsumerGroup
    @consumer_group_id = "integration_test_consumer_group_extensions"
    VCR.insert_cassette('extensions/consumer_group_extensions')
    ConsumerGroupSupport.create_consumer_group
    ConsumerSupport.create_consumer
  end

  def teardown
    ConsumerSupport.destroy_consumer
    ConsumerGroupSupport.destroy_consumer_group
    VCR.eject_cassette
  end



  def test_add_consumers_by_id
    response = @extension.add_consumers_by_id(ConsumerGroupSupport.consumer_group_id, [ConsumerSupport.consumer_id])
    assert_equal(200, response.code)
    assert(Array === response)
    assert(response.include?(ConsumerSupport.consumer_id))
  end

  def test_remove_consumers_by_id
    response = @extension.remove_consumers_by_id(ConsumerGroupSupport.consumer_group_id, [ConsumerSupport.consumer_id])
    assert_equal(200, response.code)
    assert(Array === response)
    assert(!response.include?(ConsumerSupport.consumer_id))
  end

end


