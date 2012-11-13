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


class TestConsumerExtension < MiniTest::Unit::TestCase

  def self.before_suite
    RepositorySupport.create_and_sync_repo(:importer_and_distributor => true)
  end

  def self.after_suite
    RepositorySupport.destroy_repo
  end

  def setup
    @resource = Runcible::Resources::Consumer
    @extension = Runcible::Extensions::Consumer
    @consumer_id = "integration_test_consumer_extensions11000"
    VCR.insert_cassette('extensions/consumer_extensions')
    create_consumer
    bind_repo
  end

  def teardown
    destroy_consumer
    VCR.eject_cassette
  end

  def create_consumer
    destroy_consumer
    @resource.create(@consumer_id, :name=>"boo")
  end

  def destroy_consumer
    @resource.delete(@consumer_id)
  rescue
  end

  def bind_repo
    tasks = @extension.bind_all(@consumer_id, RepositorySupport.repo_id)
    RepositorySupport.wait_on_tasks(tasks)
  end

  def test_bind_all
    @extension.unbind_all(@consumer_id, RepositorySupport.repo_id)
    response = @extension.bind_all(@consumer_id, RepositorySupport.repo_id)
    RepositorySupport.wait_on_tasks(response)

    refute_empty response
  end

  def test_unbind_all
    response = @extension.unbind_all(@consumer_id, RepositorySupport.repo_id)
    RepositorySupport.wait_on_tasks(response)

    refute_empty response
  end

  def test_install_content
    response = @extension.install_content(@consumer_id, "rpm", ["zsh", "foo"])
    assert_equal(202, response.code)
    assert(response["task_id"])
  end

  def test_update_content
    response = @extension.update_content(@consumer_id, "rpm", ["zsh", "foo"])
    assert_equal(202, response.code)
    assert(response["task_id"])
  end

  def test_uninstall_content
    response = @extension.uninstall_content(@consumer_id, "rpm", ["zsh", "foo"])
    assert_equal(202, response.code)
    assert(response["task_id"])
  end

  def test_generate_content
    content = @extension.generate_content("rpm", ["unit_1", "unit_2"])

    refute_empty content
    refute_empty content.select{ |unit| unit[:type_id] == "rpm" }
  end

end


