require 'rubygems'
require './lib/runcible/resources/consumer'
require './lib/runcible/extensions/consumer'

class ConsumerSupport
  def initialize
    @consumer_resource  = TestRuncible.server.resources.consumer
  end

  def self.consumer_id
    'integration_test_consumer_support'
  end

  def create_consumer(package_profile = false)
    destroy_consumer
    consumer = @consumer_resource.create(self.class.consumer_id)
    if package_profile
      @consumer_resource.upload_profile(self.class.consumer_id, 'rpm',
                                        [{'name' => 'elephant', 'version' => '0.2', 'release' => '0.7',
                                          'epoch' => 0, 'arch' => 'noarch', 'vendor' => 'Fedora'}])
    end
    return consumer
  rescue => e
    raise e
  end

  def destroy_consumer
    @consumer_resource.delete(self.class.consumer_id)
  rescue => e
    raise e unless e.class == RestClient::ResourceNotFound
  end
end
