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
