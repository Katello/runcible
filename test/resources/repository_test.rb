# Copyright 2012 Red Hat, Inc.
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

    assert_equal 201, response.code
    assert_equal RepositorySupport.repo_id, response['id']
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
    RepositorySupport.wait_on_tasks(response)

    assert_equal 202, response.code
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

  def test_path
    path = @resource.path

    assert_match "repositories/", path
  end

  def test_repository_path_with_id
    path = @resource.path(RepositorySupport.repo_id)

    assert_match "repositories/#{RepositorySupport.repo_id}", path
  end

  def test_update
    response = @resource.update(RepositorySupport.repo_id, { :description => "updated_description_" + RepositorySupport.repo_id })

    assert_equal 200, response.code
    assert_equal "updated_description_" + RepositorySupport.repo_id, response["description"]
  end

  def test_retrieve
    response = @resource.retrieve(RepositorySupport.repo_id)

    assert_equal 200, response.code
    assert_equal RepositorySupport.repo_id, response["display_name"]
  end

  def test_retrieve_all
    response = @resource.retrieve_all()

    assert_equal 200, response.code
    refute_empty response
  end

  def test_search
    response = @resource.search({})

    assert_equal 200, response.code
    refute_empty response
  end
end


class TestRespositoryDistributor < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase
  def setup
    super
    RepositorySupport.create_repo(:importer => false)
  end

  def teardown
    RepositorySupport.destroy_repo
    super
  end


  def test_associate_distributor
    distributor_config = {"relative_url" => "/", "http" => true, "https" => true}
    response = @resource.associate_distributor(RepositorySupport.repo_id, "yum_distributor", distributor_config)

    assert_equal 201, response.code
    assert_equal "yum_distributor", response['distributor_type_id']
  end

  def test_delete_distributor
    distributor_config = {"relative_url" => "/", "http" => true, "https" => true}
    @resource.associate_distributor(RepositorySupport.repo_id, "yum_distributor",
                                    distributor_config, {:distributor_id => "dist_1"})

    response = @resource.delete_distributor(RepositorySupport.repo_id, "dist_1")
    RepositorySupport.wait_on_tasks(response)

    assert_equal 202, response.code
  end

  def test_update_distributor
    distributor_config = {"relative_url" => "/", "http" => true, "https" => true}
    distributor = @resource.associate_distributor(RepositorySupport.repo_id, "yum_distributor",
                                    distributor_config, {:distributor_id => "dist_1"})

    response = @resource.update_distributor(RepositorySupport.repo_id, distributor['id'],
                                         {:relative_url=>"/new_path/"})
    assert_equal 202, response.code
  end

end



class TestRepositoryImporter < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase

  def setup
    super
    RepositorySupport.create_repo(:importer => false)
  end

  def teardown
    RepositorySupport.destroy_repo
    super
  end

  def test_associate_importer
    response = @resource.associate_importer(RepositorySupport.repo_id, "yum_importer", {})

    assert_equal 201, response.code
    assert_equal "yum_importer", response['importer_type_id']
  end

  def test_delete_importer
    @resource.associate_importer(RepositorySupport.repo_id, "yum_importer", {})
    response = @resource.delete_importer(RepositorySupport.repo_id, "yum_importer")

    assert_equal 200, response.code
  end

  def test_update_importer
    @resource.associate_importer(RepositorySupport.repo_id, "yum_importer", {})
    response = @resource.update_importer(RepositorySupport.repo_id, "yum_importer",
                                         {:feed_url=>"http://katello.org/repo/"})
    assert_equal 200, response.code
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

  def test_sync
    RepositorySupport.create_repo
    response = @resource.sync(RepositorySupport.repo_id)
    RepositorySupport.task = response[0]

    assert_equal    202, response.code
    refute_empty    response
    assert_includes response.first["call_request_tags"], 'pulp:action:sync'
  end

  def test_sync_repo_with_yum_importer
    RepositorySupport.create_repo(:importer => true)
    response = @resource.sync(RepositorySupport.repo_id)
    RepositorySupport.task = response.first

    assert_equal    202, response.code
    refute_empty    response
    assert_includes response.first["call_request_tags"], 'pulp:action:sync'
  end
end


class TestResourcesRepositoryRequiresSync < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase

  def setup
    super
    RepositorySupport.create_and_sync_repo(:importer_and_distributor => true)
  end

  def teardown
    RepositorySupport.destroy_repo
    super
  end

  def test_publish
    response = @resource.publish(RepositorySupport.repo_id, RepositorySupport.distributor)
    RepositorySupport.wait_on_task(response)

    assert_equal    202, response.code
    assert_includes response['call_request_tags'], 'pulp:action:publish'
  end

  def test_unassociate_units
    response = @resource.unassociate_units(RepositorySupport.repo_id, {})
    RepositorySupport.wait_on_task(response)

    assert_equal 202, response.code
  end

  def test_unit_search
    response = @resource.unit_search(RepositorySupport.repo_id, {})

    assert_equal 200, response.code
    refute_empty response
  end

  def test_sync_history
    response = @resource.sync_history(RepositorySupport.repo_id)

    assert        200, response.code
    refute_empty  response
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

    assert_equal    202, response.code
    assert_includes response['call_request_tags'], 'pulp:action:associate'
  end

end
