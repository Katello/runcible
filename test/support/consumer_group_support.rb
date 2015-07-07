require 'rubygems'
require './lib/runcible/resources/consumer_group'
require './lib/runcible/extensions/consumer_group'

class ConsumerGroupSupport
  def initialize
    @consumer_group_resource = TestRuncible.server.extensions.consumer_group
  end

  def self.consumer_group_id
    'integration_test_consumer_group_support'
  end

  def create_consumer_group
    destroy_consumer_group
    consumer_group = @consumer_group_resource.create(self.class.consumer_group_id)
    return consumer_group
  rescue => e
    raise e unless e.class == RestClient::ResourceNotFound
  end

  def destroy_consumer_group
    @consumer_group_resource.delete(self.class.consumer_group_id)
  rescue => e
    raise e unless e.class == RestClient::ResourceNotFound
  end
end
