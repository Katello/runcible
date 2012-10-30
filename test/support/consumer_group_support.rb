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
require './lib/runcible/resources/consumer_group'
require './lib/runcible/extensions/consumer_group'
module ConsumerGroupSupport

  @consumer_group_resource = Runcible::Extensions::ConsumerGroup
  @consumer_group_id = "integration_test_consumer_group_support"

  def self.consumer_group_id
    @consumer_group_id
  end

  def self.create_consumer_group()
    consumer_group = {}
    destroy_consumer_group
    VCR.use_cassette('consumer_group_support') do
      consumer_group = @consumer_group_resource.create(@consumer_group_id)
    end
    return consumer_group
  rescue Exception => e
    p "TestPulpConsumerGroup: Consumer #{@consumer_group_id} already existed."
  end

  def self.destroy_consumer_group
    VCR.use_cassette('consumer_group_support') do
      @consumer_group_resource.delete(@consumer_group_id)
    end

  rescue Exception => e
    raise e unless e.class == RestClient::ResourceNotFound
    p "TestPulpConsumerGroup: No consumer group #{@consumer_group_id} to delete."
  end

end
