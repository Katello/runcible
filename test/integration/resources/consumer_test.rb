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
require './lib/runcible/resources/consumer'
require './lib/runcible/extensions/consumer'
require './test/integration/resources/helpers/repository_helper'
require 'active_support/core_ext/time/calculations'


module TestConsumerBase

  def setup
    @resource = Runcible::Resources::Consumer
    @extension = Runcible::Extensions::Consumer
    @consumer_id = "integration_test_consumer"
    VCR.insert_cassette('pulp_consumer')
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
  end


  def bind_repo
    @extension.bind_all(@consumer_id, RepositoryHelper.repo_id)
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
    assert response['id'] == @consumer_id
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
    assert response.code == 200
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

class TestGeneralMethods  < ConsumerTests
  def test_consumer_path
    path = @resource.path
    assert_match('consumers/', path)
  end

  def test_consumer_path_with_id
    path = @resource.path(@consumer_id)
    assert_match("consumers/#{@consumer_id}/", path)
  end

  def test_retrieve
    response = @resource.retrieve(@consumer_id)
    assert response.length > 0
    assert response['id'] == @consumer_id
  end

  def test_update
    description = "Test description"
    response = @resource.update(@consumer_id, :description => description)
    assert response.code == 200
    consumer = @resource.retrieve(@consumer_id)
    assert consumer['description'] == description
  end
end


class TestProfiles < ConsumerTests
  def test_upload_profile
    packages = [{"vendor" => "FedoraHosted", "name" => "elephant",
                 "version" => "0.3", "release" => "0.8",
                 "arch" => "noarch"}]

    response = @resource.upload_profile(@consumer_id, 'rpm', packages)
    assert_equal(packages, response['profile'])
  end

  def test_profile
    packages = [{"vendor" => "FedoraHosted", "name" => "elephant",
                 "version" => "0.3", "release" => "0.8",
                 "arch" => "noarch"}]

    @resource.upload_profile(@consumer_id, 'rpm', packages)
    response = @resource.profile(@consumer_id, 'rpm')
    assert_equal(@consumer_id, response["consumer_id"])
    assert_equal(packages, response["profile"])
  end
end

class TestConsumerRequiresRepo < ConsumerTests

  def self.before_suite
    RepositoryHelper.create_and_sync_repo(:importer_and_distributor => true)
  end

  def self.after_suite
    RepositoryHelper.destroy_repo
  end

  def setup
    super
    bind_repo
  end

  def test_bind
    distro_id = RepositoryHelper.distributor()['id']
    @resource.unbind(@consumer_id, RepositoryHelper.repo_id, distro_id)
    assert(@resource.retrieve_bindings(@consumer_id).empty?)

    response = @resource.bind(@consumer_id, RepositoryHelper.repo_id, distro_id)
    assert_equal(RepositoryHelper.repo_id, response[:repo_id])
    assert(!@resource.retrieve_bindings(@consumer_id).empty?)
  end

  def test_unbind
    distro_id = RepositoryHelper.distributor()['id']
    assert(!@resource.retrieve_bindings(@consumer_id).empty?)
    response = @resource.unbind(@consumer_id, RepositoryHelper.repo_id, distro_id)
    assert(@resource.retrieve_bindings(@consumer_id).empty?)
  end

end


