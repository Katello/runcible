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

require './test/integration/resources/helpers/repository_helper'
require './lib/runcible'


module TestResourcesRepositoryBase
  include RepositoryHelper

  def setup
    @resource = Runcible::Resources::Repository
    @extension = Runcible::Extensions::Repository
    VCR.insert_cassette('pulp_repository')
  end

  def teardown
    VCR.eject_cassette
  end

end


class TestResourcesRepositoryCreate < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase

  def teardown
    RepositoryHelper.destroy_repo
    super
  end

  def test_create
    response = RepositoryHelper.create_repo
    assert response.code == 201
    assert response['id'] == RepositoryHelper.repo_id
  end
end


class TestResourcesRepositoryDelete < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase

  def setup
    super
    RepositoryHelper.create_repo
  end

  def test_delete
    response = @resource.delete(RepositoryHelper.repo_id)
    assert response.code == 200
  end

end


class TestResourcesRepository < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase
  
  def self.before_suite
    RepositoryHelper.create_repo(:importer => true)
  end

  def self.after_suite
    RepositoryHelper.destroy_repo
  end

  def test_repository_path
    path = @resource.path
    assert_match("repositories/", path)
  end

  def test_repository_path_with_id
    path = @resource.path(RepositoryHelper.repo_id)
    assert_match("repositories/#{RepositoryHelper.repo_id}", path)
  end

  def test_update
    response = @resource.update(RepositoryHelper.repo_id, { :description => "updated_description_" + RepositoryHelper.repo_id })
    assert response.code == 200
    assert response["description"] == "updated_description_" + RepositoryHelper.repo_id
  end

  def test_retrieve
    response = @resource.retrieve(RepositoryHelper.repo_id)
    assert response.code == 200
    assert response["display_name"] == RepositoryHelper.repo_id
  end

  def test_retrieve_with_details
    response = @resource.retrieve(RepositoryHelper.repo_id, {:details => true})
    assert response.code == 200
    assert response.has_key?("distributors")
    assert response.has_key?("importers")
  end

  def test_retrieve_all
    response = @resource.retrieve_all()
    assert response.code == 200
    assert response.collect{ |repo| repo["display_name"] == RepositoryHelper.repo_id }.length > 0
  end

  def test_search
    response = @resource.search({})
    assert response.code == 200
    assert response.collect{ |repo| repo["display_name"] == RepositoryHelper.repo_id }.length > 0
  end

  def test_associate_importer
    response = @resource.associate_importer(RepositoryHelper.repo_id, "yum_importer", {})
    assert response.code == 201
    assert response['importer_type_id'] == "yum_importer"
  end

  def test_associate_distributor
    distributor_config = {"relative_url" => "/", "http" => true, "https" => true}

    response = @resource.associate_distributor(RepositoryHelper.repo_id, "yum_distributor", distributor_config)
    assert response.code == 201
    assert response['distributor_type_id'] == "yum_distributor"
  end

end


class TestResourcesRepositorySync < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase
  
  def setup
    super
    VCR.eject_cassette
    VCR.insert_cassette('pulp_repository_sync')
  end

  def teardown
    RepositoryHelper.destroy_repo
    super
  end

  def test_sync_repo
    RepositoryHelper.create_repo
    response = @resource.sync(RepositoryHelper.repo_id)
    RepositoryHelper.task = response[0]

    assert response.code == 202
    assert response.length == 1
    assert response[0]["call_request_tags"].include?('pulp:action:sync')
  end

  def test_sync_repo_with_yum_importer
    RepositoryHelper.create_repo(:importer => true)
    response = @resource.sync(RepositoryHelper.repo_id)
    RepositoryHelper.task = response.first

    assert response.code == 202
    assert response.length == 1
    assert response.first["call_request_tags"].include?('pulp:action:sync')
  end
end

class TestResourcesRepositoryClone < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase

  def setup
    super
    @clone_name = RepositoryHelper.repo_id + "_clone"
    RepositoryHelper.destroy_repo(@clone_name)
    RepositoryHelper.destroy_repo
    RepositoryHelper.create_and_sync_repo(:importer => true)
    @extension.create_with_importer(@clone_name, :id => "yum_importer")
  end

  def teardown
    RepositoryHelper.destroy_repo(@clone_name)
    RepositoryHelper.destroy_repo
    super
  end

  def test_unit_copy
    response = @resource.unit_copy(@clone_name, RepositoryHelper.repo_id)
    RepositoryHelper.task = response
    assert response.code == 202
    assert response['call_request_tags'].include?('pulp:action:associate')
  end

end
