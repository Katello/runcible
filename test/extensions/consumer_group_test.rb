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
require './lib/runcible/resources/consumer_group'
require './lib/runcible/extensions/consumer_group'
require './test/support/consumer_support'
require './test/support/consumer_group_support'
require './test/support/repository_support'


class TestConsumerGroupExtension < MiniTest::Unit::TestCase

  def self.before_suite
    RepositorySupport.create_and_sync_repo(:importer_and_distributor => true)
  end

  def self.after_suite
    RepositorySupport.destroy_repo
  end

  def setup
    @resource = Runcible::Resources::ConsumerGroup
    @extension = Runcible::Extensions::ConsumerGroup
    VCR.insert_cassette('extensions/consumer_group_extensions')

    #ConsumerSupport.destroy_consumer
    #ConsumerGroupSupport.destroy_consumer_group

    ConsumerGroupSupport.create_consumer_group
    ConsumerSupport.create_consumer

    criteria = {:criteria =>
                   {:filters =>
                     {:id => {"$in" => [ConsumerSupport.consumer_id]}}}}
    distro_id = RepositorySupport.distributor()['id']

    Runcible::Resources::Consumer.bind(ConsumerSupport.consumer_id, RepositorySupport.repo_id, distro_id)
    @resource.associate(ConsumerGroupSupport.consumer_group_id, criteria)
    @consumer_group_id = ConsumerGroupSupport.consumer_group_id
  end

  def teardown
    ConsumerSupport.destroy_consumer
    ConsumerGroupSupport.destroy_consumer_group
    VCR.eject_cassette
  end

  def test_add_consumers_by_id
    response = @extension.add_consumers_by_id(ConsumerGroupSupport.consumer_group_id, [ConsumerSupport.consumer_id])

    assert_equal    200, response.code
    refute_empty    response
    assert_includes response, ConsumerSupport.consumer_id
  end

  def test_remove_consumers_by_id
    response = @extension.remove_consumers_by_id(ConsumerGroupSupport.consumer_group_id, [ConsumerSupport.consumer_id])

    assert_equal    200, response.code
    assert_includes response, ConsumerSupport.consumer_id
  end

  def test_make_consumer_criteria
    criteria = @extension.make_consumer_criteria([ConsumerSupport.consumer_id])

    assert_kind_of  Hash, criteria
    refute_empty    criteria[:criteria][:filters][:id]["$in"]
  end

  def test_install_content
    response = @extension.install_content(@consumer_group_id, "rpm", ["zsh", "foo"])
    task     = response.first
    RepositorySupport.wait_on_task(task)

    assert_equal 202, response.code
    assert       task["task_id"]
  end

  def test_update_content
    response = @extension.update_content(@consumer_group_id, "rpm", ["zsh", "foo"])
    task     = response.first
    RepositorySupport.wait_on_task(task)

    assert_equal 202, response.code
    assert       task["task_id"]
  end

  def test_uninstall_content
    response = @extension.uninstall_content(@consumer_group_id, "rpm", ["zsh", "foo"])
    task     = response.first
    RepositorySupport.wait_on_task(task)

    assert_equal 202, response.code
    assert       task["task_id"]
  end

  def test_generate_content
    content = @extension.generate_content("rpm", ["unit_1", "unit_2"])

    refute_empty content
    refute_empty content.select{ |unit| unit[:type_id] == "rpm" }
  end

end