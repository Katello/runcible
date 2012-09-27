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
require './lib/runcible/extensions/repository'
require './lib/runcible/extensions/importer'
require './lib/runcible/extensions/yum_importer'
require './lib/runcible/extensions/distributor'
require './lib/runcible/extensions/yum_distributor'


module TestExtensionsRepositoryBase
  include RepositoryHelper

  def setup
    @extension = Runcible::Extensions::Repository
    VCR.insert_cassette('extensions/pulp_repository_extensions')
  end

  def teardown
    VCR.eject_cassette
  end

end

class TestExtensionsRepositoryCreate < MiniTest::Unit::TestCase
  include TestExtensionsRepositoryBase
  
  def teardown
    super
    RepositoryHelper.destroy_repo
  end

  def test_create_with_importer
    response = @extension.create_with_importer(RepositoryHelper.repo_id, {:id=>"yum_importer"})
    assert response.code == 201

    response = @extension.retrieve(RepositoryHelper.repo_id, {:details => true})
    assert response['id'] == RepositoryHelper.repo_id
    assert response['importers'].first['importer_type_id'] == 'yum_importer'
  end


  def test_create_with_importer_object
    response = @extension.create_with_importer(RepositoryHelper.repo_id, Runcible::Extensions::YumImporter.new())
    assert response.code == 201

    response = @extension.retrieve(RepositoryHelper.repo_id, {:details => true})
    assert response['id'] == RepositoryHelper.repo_id
    assert response['importers'].first['importer_type_id'] == 'yum_importer'
  end


  def test_create_with_distributors
    distributors = [{'type_id' => 'yum_distributor', 'id'=>'123', 'auto_publish'=>true,
                     'config'=>{'relative_url' => '/', 'http' => true, 'https' => true}}]

    response = @extension.create_with_distributors(RepositoryHelper.repo_id, distributors)
    assert response.code == 201
    assert response['id'] == RepositoryHelper.repo_id
  end

  def test_create_with_distributor_object
    response = @extension.create_with_distributors(RepositoryHelper.repo_id, [Runcible::Extensions::YumDistributor.new(
        '/path', true, true)])
    assert response.code == 201

    response = @extension.retrieve(RepositoryHelper.repo_id, {:details => true})
    assert response['id'] == RepositoryHelper.repo_id
    assert response['distributors'].first['distributor_type_id'] == 'yum_distributor'
  end

  def test_create_with_importer_and_distributors
    distributors = [{'type_id' => 'yum_distributor', 'id'=>'123', 'auto_publish'=>true,
                     'config'=>{'relative_url' => '/', 'http' => true, 'https' => true}}]
    response = @extension.create_with_importer_and_distributors(RepositoryHelper.repo_id, {:id=>'yum_importer'}, distributors)
    assert response.code == 201

    response = @extension.retrieve(RepositoryHelper.repo_id, {:details => true})
    assert response['id'] == RepositoryHelper.repo_id
    assert response['importers'].first['importer_type_id'] == 'yum_importer'
  end

  def test_create_with_importer_and_distributors_objects
    distributors = [Runcible::Extensions::YumDistributor.new(
            '/path', true, true)]
    importer = Runcible::Extensions::YumImporter.new()
    response = @extension.create_with_importer_and_distributors(RepositoryHelper.repo_id, importer, distributors)
    assert response.code == 201

    response = @extension.retrieve(RepositoryHelper.repo_id, {:details => true})
    assert response['id'] == RepositoryHelper.repo_id
    assert response['importers'].first['importer_type_id'] == 'yum_importer'
  end


end

class TestExtensionsRepositorySearch < MiniTest::Unit::TestCase
  include TestExtensionsRepositoryBase

  def setup
    super
    RepositoryHelper.create_repo
  end

  def teardown
    RepositoryHelper.destroy_repo
    super
  end

  def test_search_by_repository_ids
    response = @extension.search_by_repository_ids([RepositoryHelper.repo_id])
    assert response.code == 200

    assert response.collect{ |repo| repo["display_name"] == RepositoryHelper.repo_id }.length > 0
  end

end


class TestExtensionsRepositoryCopy < MiniTest::Unit::TestCase
  include TestExtensionsRepositoryBase

  def setup
    super
    @clone_name = RepositoryHelper.repo_id + "_clone"
    RepositoryHelper.destroy_repo(@clone_name)
    RepositoryHelper.destroy_repo
    RepositoryHelper.create_and_sync_repo(:importer => true)
    @extension.create_with_importer(@clone_name, {:id=>"yum_importer"})
  end

  def teardown
    RepositoryHelper.destroy_repo(@clone_name)
    RepositoryHelper.destroy_repo
    super
  end

  def test_package_copy
    response = @extension.rpm_copy(RepositoryHelper.repo_id, @clone_name)
    RepositoryHelper.task = response
    assert response.code == 202
    assert response['tags'].include?('pulp:action:associate')
  end

  def test_errata_copy
     response = @extension.errata_copy(RepositoryHelper.repo_id, @clone_name)
     RepositoryHelper.task = response
     assert response.code == 202
     assert response['tags'].include?('pulp:action:associate')
  end

  def test_distribution_copy
     response = @extension.distribution_copy(RepositoryHelper.repo_id, @clone_name)
     RepositoryHelper.task = response
     assert response.code == 202
     assert response['tags'].include?('pulp:action:associate')
  end


end

