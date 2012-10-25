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

require './test/support/repository_support'
require './lib/runcible'


module TestResourcesRepositoryBase
  include RepositorySupport

  def setup
    @resource = Runcible::Resources::Repository
    @extension = Runcible::Extensions::Repository
    VCR.insert_cassette('repository')
  end

  def teardown
    VCR.eject_cassette
  end

end


class TestResourcesRepositoryCreate < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase

  def teardown
    RepositorySupport.destroy_repo
    super
  end

  def test_create
    response = RepositorySupport.create_repo
    assert response.code == 201
    assert response['id'] == RepositorySupport.repo_id
  end
end


class TestResourcesRepositoryDelete < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase

  def setup
    super
    RepositorySupport.create_repo
  end

  def test_delete
    response = @resource.delete(RepositorySupport.repo_id)
    assert response.code == 200
  end

end


class TestResourcesRepository < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase
  
  def self.before_suite
    RepositorySupport.create_repo(:importer => true)
  end

  def self.after_suite
    RepositorySupport.destroy_repo
  end

  def test_repository_path
    path = @resource.path
    assert_match("repositories/", path)
  end

  def test_repository_path_with_id
    path = @resource.path(RepositorySupport.repo_id)
    assert_match("repositories/#{RepositorySupport.repo_id}", path)
  end

  def test_update
    response = @resource.update(RepositorySupport.repo_id, { :description => "updated_description_" + RepositorySupport.repo_id })
    assert response.code == 200
    assert response["description"] == "updated_description_" + RepositorySupport.repo_id
  end

  def test_retrieve
    response = @resource.retrieve(RepositorySupport.repo_id)
    assert response.code == 200
    assert response["display_name"] == RepositorySupport.repo_id
  end

  def test_retrieve_with_details
    response = @resource.retrieve(RepositorySupport.repo_id, {:details => true})
    assert response.code == 200
    assert response.has_key?("distributors")
    assert response.has_key?("importers")
  end

  def test_retrieve_all
    response = @resource.retrieve_all()
    assert response.code == 200
    assert response.collect{ |repo| repo["display_name"] == RepositorySupport.repo_id }.length > 0
  end

  def test_search
    response = @resource.search({})
    assert response.code == 200
    assert response.collect{ |repo| repo["display_name"] == RepositorySupport.repo_id }.length > 0
  end

  def test_associate_importer
    response = @resource.associate_importer(RepositorySupport.repo_id, "yum_importer", {})
    assert response.code == 201
    assert response['importer_type_id'] == "yum_importer"
  end

  def test_associate_distributor
    distributor_config = {"relative_url" => "/", "http" => true, "https" => true}

    response = @resource.associate_distributor(RepositorySupport.repo_id, "yum_distributor", distributor_config)
    assert response.code == 201
    assert response['distributor_type_id'] == "yum_distributor"
  end

end


class TestResourcesRepositorySync < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase
  
  def setup
    super
    VCR.eject_cassette
    VCR.insert_cassette('repository_sync')
  end

  def teardown
    RepositorySupport.destroy_repo
    super
  end

  def test_sync_repo
    RepositorySupport.create_repo
    response = @resource.sync(RepositorySupport.repo_id)
    RepositorySupport.task = response[0]

    assert response.code == 202
    assert response.length == 1
    assert response[0]["call_request_tags"].include?('pulp:action:sync')
  end

  def test_sync_repo_with_yum_importer
    RepositorySupport.create_repo(:importer => true)
    response = @resource.sync(RepositorySupport.repo_id)
    RepositorySupport.task = response.first

    assert response.code == 202
    assert response.length == 1
    assert response.first["call_request_tags"].include?('pulp:action:sync')
  end
end

class TestResourcesRepositoryClone < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase

  def setup
    super
    @clone_name = RepositorySupport.repo_id + "_clone"
    RepositorySupport.create_and_sync_repo(:importer => true)
    @extension.create_with_importer(@clone_name, :id => "yum_importer")
  end

  def teardown
    RepositorySupport.destroy_repo(@clone_name)
    RepositorySupport.destroy_repo
    super
  end

  def test_unit_copy
    response = @resource.unit_copy(@clone_name, RepositorySupport.repo_id)
    RepositorySupport.task = response
    assert response.code == 202
    assert response['call_request_tags'].include?('pulp:action:associate')
  end

end
