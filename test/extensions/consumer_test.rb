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
require './lib/runcible/resources/consumer'
require './lib/runcible/extensions/consumer'
require './test/support/repository_support'
require './test/support/consumer_support'

class TestConsumerExtension < MiniTest::Unit::TestCase

  def self.before_suite
    @@repo_support = RepositorySupport.new
    @@consumer_support = ConsumerSupport.new
    @@repo_support.create_and_sync_repo(:importer_and_distributor => true)
  end

  def self.after_suite
    @@repo_support.destroy_repo
  end

  def setup
    @resource = TestRuncible.server.resources.consumer
    @extension = TestRuncible.server.extensions.consumer
    @consumer_id = "integration_test_consumer_extensions11000"
    VCR.insert_cassette('extensions/consumer_extensions')
    @@consumer_support.destroy_consumer
    @@consumer_support.create_consumer(true)
    @consumer_id = ConsumerSupport.consumer_id
    bind_repo
  end

  def teardown
    @@consumer_support.destroy_consumer
    VCR.eject_cassette
  end

  def bind_repo
    tasks = @extension.bind_all(@consumer_id, RepositorySupport.repo_id,
                                Runcible::Models::YumDistributor.type_id, {:notify_agent=>false})
    @@repo_support.wait_on_tasks(tasks)
  end

  def test_activate_node
    response = @extension.activate_node(@consumer_id)
    refute_empty response
  end

  def test_deactivate_node
    @extension.activate_node(@consumer_id)
    response = @extension.deactivate_node(@consumer_id)
    refute_empty response
  end

  def test_bind_all
    tasks = @extension.unbind_all(@consumer_id, RepositorySupport.repo_id, Runcible::Models::YumDistributor.type_id)
    @@repo_support.wait_on_tasks(tasks)

    response = @extension.bind_all(@consumer_id, RepositorySupport.repo_id,
                                   Runcible::Models::YumDistributor.type_id, {:notify_agent=>false})
    @@repo_support.wait_on_tasks(response)

    refute_empty response
  end

  def test_unbind_all
    response = @extension.unbind_all(@consumer_id, RepositorySupport.repo_id,
                                     Runcible::Models::YumDistributor.type_id)
    @@repo_support.wait_on_tasks(response)

    refute_empty response
  end

  def test_install_content
    response = @extension.install_content(@consumer_id, "rpm", ["zsh", "foo"])
    @@repo_support.wait_on_task(response)

    assert_equal  202, response.code
    assert        response["task_id"]
  end

  def test_update_content
    response = @extension.update_content(@consumer_id, "rpm", ["zsh", "foo"])
    @@repo_support.wait_on_task(response)

    assert_equal 202, response.code
    assert       response["task_id"]
  end

  def test_uninstall_content
    response = @extension.uninstall_content(@consumer_id, "rpm", ["zsh", "foo"])
    @@repo_support.wait_on_task(response)

    assert_equal 202, response.code
    assert       response["task_id"]
  end

  def test_generate_content
    content = @extension.generate_content("rpm", ["unit_1", "unit_2"])

    refute_empty content
    refute_empty content.select{ |unit| unit[:type_id] == "rpm" }
  end

  def test_generate_content_all
    content = @extension.generate_content("rpm", ["unit_1"], {:all => true})

    refute_empty content
    assert_equal "rpm", content.first[:type_id]
    assert_empty content.first[:unit_key]
  end

  def test_applicable_errata
    response  = @extension.applicable_errata(@consumer_id)

    assert_equal 200, response.code
    refute_empty response['erratum'][ConsumerSupport.consumer_id]
  end

end
