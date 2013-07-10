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


module TestConsumerBase

  def setup
    @resource = Runcible::Resources::Consumer
    @extension = Runcible::Extensions::Consumer
    @consumer_id = "integration_test_consumer"
    VCR.insert_cassette('consumer')
  end

  def teardown
    VCR.eject_cassette
  end

  def create_consumer(package_profile = false)
    consumer = @resource.create(@consumer_id, :name=>"boo")
    if package_profile
      @consumer_resource.upload_profile(@consumer_id,'rpm',[{"name" => "elephant", "version" => "0.2", "release" => "0.7",
                                                                "epoch" => 0, "arch" => "noarch"}])
    end
    consumer
  end

  def destroy_consumer
    @resource.delete(@consumer_id)
  rescue
  end

end

class ConsumerTests < MiniTest::Unit::TestCase
  include TestConsumerBase

  def setup
    super
    create_consumer
  end

  def teardown
    destroy_consumer
    super
  end

end


class TestConsumerCreate < MiniTest::Unit::TestCase
  include TestConsumerBase

  def teardown
    destroy_consumer
    super
  end

  def test_create
    response = create_consumer

    assert response.kind_of? Hash
    assert_equal @consumer_id, response['id']
  end

end

class TestConsumerDestroy < MiniTest::Unit::TestCase
  include TestConsumerBase

  def setup
    super
    create_consumer
  end

  def test_destroy
    response = destroy_consumer

    assert_equal 200, response.code
  end

end


class TestGeneralMethods < MiniTest::Unit::TestCase
  include TestConsumerBase

  def setup
    super
    create_consumer
  end

  def teardown
    destroy_consumer
    super
  end

  def test_path
    path = @resource.path

    assert_match 'consumers/', path
  end

  def test_consumer_path_with_id
    path = @resource.path(@consumer_id)

    assert_match "consumers/#{@consumer_id}/", path
  end

  def test_retrieve
    response = @resource.retrieve(@consumer_id)

    refute_empty response
    assert_equal @consumer_id, response['id']
  end

  def test_update
    description = "Test description"
    response = @resource.update(@consumer_id, :description => description)

    assert_equal 200, response.code
    assert_equal description, response['description']
  end

end


class TestProfiles < MiniTest::Unit::TestCase
  include TestConsumerBase

  def setup
    super
    create_consumer
  end

  def teardown
    destroy_consumer
    super
  end

  def test_upload_profile
    packages = [{"vendor" => "FedoraHosted", "name" => "elephant",
                 "version" => "0.3", "release" => "0.8",
                 "arch" => "noarch"}]
    response = @resource.upload_profile(@consumer_id, 'rpm', packages)

    assert_equal packages, response['profile']
  end

  def test_retrieve_profile
    packages = [{"vendor" => "FedoraHosted", "name" => "elephant",
                 "version" => "0.3", "release" => "0.8",
                 "arch" => "noarch"}]
    @resource.upload_profile(@consumer_id, 'rpm', packages)
    response = @resource.retrieve_profile(@consumer_id, 'rpm')

    assert_equal @consumer_id, response["consumer_id"]
    assert_equal packages, response["profile"]
  end

end


class ConsumerRequiresRepoTests < MiniTest::Unit::TestCase
  include TestConsumerBase

  def self.before_suite
    ConsumerSupport.create_consumer(true)
    RepositorySupport.create_and_sync_repo(:importer_and_distributor => true)
  end

  def self.after_suite
    ConsumerSupport.destroy_consumer
    RepositorySupport.destroy_repo
  end

  def self.bind_repo
    tasks = []
    VCR.use_cassette('support/consumer') do
      distro_id = RepositorySupport.distributor()['id']
      tasks = Runcible::Resources::Consumer.bind(ConsumerSupport.consumer_id,
                                   RepositorySupport.repo_id, distro_id, {:notify_agent=>false})
      RepositorySupport.wait_on_tasks(tasks)
    end
    return tasks
  end

end


class TestConsumerBindings < ConsumerRequiresRepoTests

  def test_bind
    response = self.class.bind_repo

    refute_empty response
    assert_equal 202, response.code
  end

  def test_unbind
    self.class.bind_repo
    distro_id = RepositorySupport.distributor()['id']
    refute_empty @resource.retrieve_bindings(ConsumerSupport.consumer_id)

    response = @resource.unbind(ConsumerSupport.consumer_id, RepositorySupport.repo_id, distro_id)
    RepositorySupport.wait_on_tasks(response)

    assert_equal 202, response.code
  end

end


class TestConsumerRequiresRepo < ConsumerRequiresRepoTests
    
  def self.before_suite
    super  
    bind_repo
  end

  def test_retrieve_binding
    distributor_id = RepositorySupport.distributor()['id']
    response = @resource.retrieve_binding(ConsumerSupport.consumer_id, RepositorySupport.repo_id, distributor_id)

    assert_equal 200, response.code
    assert_equal RepositorySupport.repo_id, response['repo_id']
  end

  def test_retrieve_bindings
    response  = @resource.retrieve_bindings(ConsumerSupport.consumer_id)

    assert_equal 200, response.code
    refute_empty response
  end

  def test_applicability
    criteria  = {
      'consumer_criteria' => {
        'filters' => {'id' => {'$in' => [ConsumerSupport.consumer_id]}}
      },
      'repo_criteria' => {
        'filters' => {'id'=> {'$in'=> [RepositorySupport.repo_id]}}
      },
      'units' => {
        'erratum' => []
      }
    }
    response  = @resource.applicability(criteria)

    assert_equal 200, response.code
    refute_empty response['erratum'][ConsumerSupport.consumer_id]
  end

  def test_install_units
    response  = @resource.install_units(@consumer_id,{"units"=>["unit_key"=>{:name => "zsh"}]})
    RepositorySupport.wait_on_task(response)

    assert_equal 202, response.code
    refute_empty response
  end

  def test_update_units
    response  = @resource.update_units(@consumer_id,{"units"=>["unit_key"=>{:name => "zsh"}]})
    RepositorySupport.wait_on_task(response)

    assert_equal 202, response.code
    refute_empty response
  end

  def test_uninstall_units
    response  = @resource.uninstall_units(@consumer_id,{"units"=>["unit_key"=>{:name => "zsh"}]})
    RepositorySupport.wait_on_task(response)

    assert_equal 202, response.code
    refute_empty response
  end

end


