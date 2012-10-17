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
    @resource = Runcible::Extensions::Consumer
    @consumer_id = "integration_test_consumer"
    VCR.insert_cassette('pulp_consumer')
  end

  def teardown
    VCR.eject_cassette
  end

  def create_consumer package_profile = false
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
    @resource.bind_all(@consumer_id, RepositoryHelper.repo_id)
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

  def test_find
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

  def test_load_profile
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
  #
  #
  #def test_installed_packages
  #  response = @resource.installed_packages(@consumer_id)
  #  assert response.length > 0
  #  assert response.select { |pack| pack['name'] == 'elephant' }.length > 0
  #end
  #
  #def test_errata
  #  response = @resource.errata(@consumer_id)
  #  assert response.select { |errata| errata['id'] == "RHEA-2010:0002" }.length > 0
  #end

  def test_bind
    @resource.unbind_all(@consumer_id, RepositoryHelper.repo_id)
    assert(@resource.retrieve_bindings(@consumer_id).empty?)
    response = @resource.bind_all(@consumer_id, RepositoryHelper.repo_id)
    assert_equal(RepositoryHelper.repo_id, response.first[:repo_id])

    assert(!@resource.retrieve_bindings(@consumer_id).empty?)
  end

  def test_unbind
    assert(!@resource.retrieve_bindings(@consumer_id).empty?)
    response = @resource.unbind_all(@consumer_id, RepositoryHelper.repo_id)
    assert(@resource.retrieve_bindings(@consumer_id).empty?)
  end

  #def test_repoids
  #  response = @resource.repoids(@consumer_id)
  #  assert response.key?(RepositoryHelper.repo_id)
  #end
  #
  #def test_errata_by_consumer
  #  response = @resource.errata_by_consumer([OpenStruct.new({ :pulp_id => RepositoryHelper.repo_id})])
  #  assert response.key?("RHEA-2010:0002")
  #end
  #
  #def test_install_errata
  #  response = @resource.install_errata(@consumer_id, ['RHEA-2010:0002'], Time.now.advance(:years => 1).iso8601)
  #  @task = response
  #  assert response["method_name"] == "__installpackages"
  #end
  #
  #def test_install_packages
  #  response = @resource.install_packages(@consumer_id, ['cheetah'], Time.now.advance(:years => 1).iso8601)
  #  @task = response
  #  assert response["method_name"] == "__installpackages"
  #end
  #
  #def test_uninstall_packages
  #  response = @resource.uninstall_packages(@consumer_id, ['elephant'], Time.now.advance(:years => 1).iso8601)
  #  @task = response
  #  assert response["method_name"] == "__uninstallpackages"
  #end
  #
  #def test_update_packages
  #  response = @resource.update_packages(@consumer_id, ['elephant'], Time.now.advance(:years => 1).iso8601)
  #  @task = response
  #  assert response["method_name"] == "__updatepackages"
  #end
  #
  #def test_install_package_groups
  #  response = @resource.install_package_groups(@consumer_id, ['mammals'], Time.now.advance(:years => 1).iso8601)
  #  @task = response
  #  assert response["method_name"] == "__installpackagegroups"
  #end
  #
  #def test_uninstall_package_groups
  #  response = @resource.uninstall_package_groups(@consumer_id, ['mammals'], Time.now.advance(:years => 1).iso8601)
  #  @task = response
  #  assert response["method_name"] == "__uninstallpackagegroups"
  #end
end


=begin
    class Consumer < Runcible::Base

      def self.bind(id, repo_id, distributor_id)
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/bindings"), :payload => { :required => required })
      end

      def self.unbind(id, repo_id, distributor_id)
        call(:delete, path("#{id}/bindings/#{repo_id}/#{distributor_id}"))
      end

      def self.repos(id)
        call(:get, path("#{id}/bindings/"))
      end

      def self.install_content(id, units, options="")
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/actions/content/install/"), :payload => { :required => required })
      end

      def self.update_content(id, units, options="")
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/actions/content/update/"), :payload => { :required => required })
      end

      def self.uninstall_content(id, units, options="")
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/actions/content/uninstall/"), :payload => { :required => required })
      end
    end
=end


=begin


class TestConsumerRequiresRepo < MiniTest::Unit::TestCase
  include TestConsumerBase

  def self.before_suite
    RepositoryHelper.create_and_sync_repo
  end

  def self.after_suite
    RepositoryHelper.destroy_repo
  end

  def setup
    super
    ConsumerHelper.create_consumer(true)
    bind_repo
  end

  def teardown
    ConsumerHelper.destroy_consumer
    super
  end

  def test_installed_packages
    response = @resource.installed_packages(@consumer_id)
    assert response.length > 0
    assert response.select { |pack| pack['name'] == 'elephant' }.length > 0
  end

  def test_errata
    response = @resource.errata(@consumer_id)
    assert response.select { |errata| errata['id'] == "RHEA-2010:0002" }.length > 0
  end

  def test_bind
    @resource.unbind(@consumer_id, RepositoryHelper.repo_id)
    response = @resource.bind(@consumer_id, RepositoryHelper.repo_id)
    response = JSON.parse(response)
    assert response['repo']['name'] = RepositoryHelper.repo_name
  end

  def test_unbind
    response = @resource.unbind(@consumer_id, RepositoryHelper.repo_id)
    assert response == "true"
  end

  def test_repoids
    response = @resource.repoids(@consumer_id)
    assert response.key?(RepositoryHelper.repo_id)
  end

  def test_errata_by_consumer
    response = @resource.errata_by_consumer([OpenStruct.new({ :pulp_id => RepositoryHelper.repo_id})])
    assert response.key?("RHEA-2010:0002")
  end

  def test_install_errata
    response = @resource.install_errata(@consumer_id, ['RHEA-2010:0002'], Time.now.advance(:years => 1).iso8601)
    @task = response
    assert response["method_name"] == "__installpackages"
  end

  def test_install_packages
    response = @resource.install_packages(@consumer_id, ['cheetah'], Time.now.advance(:years => 1).iso8601)
    @task = response
    assert response["method_name"] == "__installpackages"
  end

  def test_uninstall_packages
    response = @resource.uninstall_packages(@consumer_id, ['elephant'], Time.now.advance(:years => 1).iso8601)
    @task = response
    assert response["method_name"] == "__uninstallpackages"
  end

  def test_update_packages
    response = @resource.update_packages(@consumer_id, ['elephant'], Time.now.advance(:years => 1).iso8601)
    @task = response
    assert response["method_name"] == "__updatepackages"
  end

  def test_install_package_groups
    response = @resource.install_package_groups(@consumer_id, ['mammals'], Time.now.advance(:years => 1).iso8601)
    @task = response
    assert response["method_name"] == "__installpackagegroups"
  end

  def test_uninstall_package_groups
    response = @resource.uninstall_package_groups(@consumer_id, ['mammals'], Time.now.advance(:years => 1).iso8601)
    @task = response
    assert response["method_name"] == "__uninstallpackagegroups"
  end
end
=end