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

require './test/support/repository_support'
require './lib/runcible'


module TestExtensionsRepositoryBase
  include RepositorySupport

  def setup
    @extension = Runcible::Extensions::Repository
    VCR.insert_cassette('extensions/repository_extensions', 
                        :match_requests_on => [:body_json, :path, :method])
  end

  def teardown
    VCR.eject_cassette
  end

end

class TestExtensionsRepositoryCreate < MiniTest::Unit::TestCase
  include TestExtensionsRepositoryBase

  def teardown
    super
    RepositorySupport.destroy_repo
  end

  def test_create_with_importer
    response = @extension.create_with_importer(RepositorySupport.repo_id, {:id=>"yum_importer"})
    assert_equal 201, response.code

    response = @extension.retrieve(RepositorySupport.repo_id, {:details => true})
    assert_equal RepositorySupport.repo_id, response['id']
    assert_equal "yum_importer", response['importers'].first['importer_type_id']
  end

  def test_create_with_importer_object
    response = @extension.create_with_importer(RepositorySupport.repo_id, Runcible::Extensions::YumImporter.new())
    assert_equal 201, response.code

    response = @extension.retrieve(RepositorySupport.repo_id, {:details => true})
    assert_equal RepositorySupport.repo_id, response['id']
    assert_equal "yum_importer", response['importers'].first['importer_type_id']
  end

  def test_create_with_distributors
    VCR.use_cassette('extensions/repository_create_with_importer') do

      distributors = [{'type_id' => 'yum_distributor', 'id'=>'123', 'auto_publish'=>true,
                       'config'=>{'relative_url' => '/path', 'http' => true, 'https' => true}}]
      response = @extension.create_with_distributors(RepositorySupport.repo_id, distributors)

      assert_equal 201, response.code
      assert_equal RepositorySupport.repo_id, response['id']
    end
  end

  def test_create_with_distributor_object
    repo_id = RepositorySupport.repo_id + "_distro"
    response = @extension.create_with_distributors(repo_id, [Runcible::Extensions::YumDistributor.new(
        '/path', true, true, :id => '123')])
    assert_equal 201, response.code

    response = @extension.retrieve(repo_id, {:details => true})
    assert_equal repo_id, response['id']
    assert_equal 'yum_distributor', response['distributors'].first['distributor_type_id']
  ensure
    RepositorySupport.destroy_repo(repo_id)
  end

  def test_create_with_importer_and_distributors
    distributors = [{'type_id' => 'yum_distributor', 'id'=>'123', 'auto_publish'=>true,
                     'config'=>{'relative_url' => '/', 'http' => true, 'https' => true}}]
    response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id, {:id=>'yum_importer'}, distributors)
    assert_equal 201, response.code

    response = @extension.retrieve(RepositorySupport.repo_id, {:details => true})
    assert_equal RepositorySupport.repo_id, response['id']
    assert_equal 'yum_distributor', response['distributors'].first['distributor_type_id']
  end

  def test_create_with_importer_and_distributors_objects
    distributors = [Runcible::Extensions::YumDistributor.new(
            '/path', true, true, :id => '123')]
    importer = Runcible::Extensions::YumImporter.new()
    response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id, importer, distributors)
    assert_equal 201, response.code

    response = @extension.retrieve(RepositorySupport.repo_id, {:details => true})
    assert_equal RepositorySupport.repo_id, response['id']
    assert_equal "yum_importer", response['importers'].first['importer_type_id']
  end


end

class TestExtensionsRepositoryMisc < MiniTest::Unit::TestCase
  include TestExtensionsRepositoryBase

  def setup
    super
    RepositorySupport.create_and_sync_repo(:importer_and_distributor => true)
  end

  def teardown
    RepositorySupport.destroy_repo
    super
  end

  def test_search_by_repository_ids
    response = @extension.search_by_repository_ids([RepositorySupport.repo_id])

    assert_equal 200, response.code
    refute_empty response.collect{ |repo| repo["display_name"] == RepositorySupport.repo_id }
  end

  def test_create_or_update_schedule
    response = @extension.create_or_update_schedule(RepositorySupport.repo_id, 'yum_importer', "2012-09-25T20:44:00Z/P7D")
    assert_equal 201, response.code

    response = @extension.create_or_update_schedule(RepositorySupport.repo_id, 'yum_importer', "2011-09-25T20:44:00Z/P7D")
    assert_equal 200, response.code
  end

  def test_remove_schedules
    VCR.use_cassette('extensions/repository_schedule_removal') do
      Runcible::Resources::RepositorySchedule.create(RepositorySupport.repo_id, 'yum_importer', "2012-10-25T20:44:00Z/P7D")
      response = @extension.remove_schedules(RepositorySupport.repo_id, "yum_importer")
      
      assert_equal 200, response.code
    end
  end

  def test_retrieve_with_details
    response = @extension.retrieve_with_details(RepositorySupport.repo_id)
  
    assert_equal    200, response.code
    assert_includes response, 'distributors'
  end
  
  def test_publish_all
    response = @extension.publish_all(RepositorySupport.repo_id)
    RepositorySupport.wait_on_tasks(response)

    assert_includes response.first['call_request_tags'], 'pulp:action:publish'
  end

  def test_sync_status
    response = @extension.sync_status(RepositorySupport.repo_id)

    assert_equal 200, response.code
  end

end


class TestExtensionsRepositoryUnitList < MiniTest::Unit::TestCase

  @@extension = Runcible::Extensions::Repository

  def self.before_suite
    VCR.insert_cassette('extensions/repository_unit_list', :match_requests_on => [:method, :path, :params, :body_json])
    RepositorySupport.destroy_repo
    RepositorySupport.create_and_sync_repo(:importer => true)
  end

  def self.after_suite
    RepositorySupport.destroy_repo
    VCR.eject_cassette
  end

  def test_rpm_ids
    response = @@extension.rpm_ids(RepositorySupport.repo_id)

    refute_empty    response
    assert_kind_of  String, response.first
  end

  def test_rpms
    response = @@extension.rpms(RepositorySupport.repo_id)

    refute_empty    response
    assert_kind_of  Hash, response.first
  end

  def test_errata_ids
    response = @@extension.errata_ids(RepositorySupport.repo_id)
    
    refute_empty response
  end

  def test_distributions
    response = @@extension.distributions(RepositorySupport.repo_id)

    refute_empty response
  end

  def test_package_groups
    response = @@extension.package_groups(RepositorySupport.repo_id)

    refute_empty response
  end

  def test_package_categories
    response = @@extension.package_categories(RepositorySupport.repo_id)

    refute_empty response
  end

  def test_packages_by_name
    list = @@extension.rpms(RepositorySupport.repo_id)
    rpm = list.first
    response = @@extension.packages_by_nvre(RepositorySupport.repo_id, rpm['name'])

    refute_empty response
  end

  def test_packages_by_nvre
    list = @@extension.rpms(RepositorySupport.repo_id)
    rpm = list.first
    response = @@extension.packages_by_nvre(RepositorySupport.repo_id, rpm['name'], rpm['version'],
                                            rpm['release'], rpm['epoch'])

    refute_empty response
  end

end


class TestExtensionsRepositoryCopy < MiniTest::Unit::TestCase

  @@extension = Runcible::Extensions::Repository
  @@clone_name = RepositorySupport.repo_id + "_clone"

  def self.before_suite
    VCR.insert_cassette('extensions/repository_associate')
    RepositorySupport.destroy_repo(@@clone_name)
    RepositorySupport.destroy_repo
    RepositorySupport.create_and_sync_repo(:importer => true)
    @@extension.create_with_importer(@@clone_name, {:id=>"yum_importer"})
  end

  def self.after_suite
    RepositorySupport.destroy_repo(@@clone_name)
    RepositorySupport.destroy_repo
    VCR.eject_cassette
  end

  def test_rpm_copy
    response = @@extension.rpm_copy(RepositorySupport.repo_id, @@clone_name)
    RepositorySupport.task = response

    assert_equal    202, response.code
    assert_includes response['call_request_tags'], 'pulp:action:associate'
  end

  def test_errata_copy
    response = @@extension.errata_copy(RepositorySupport.repo_id, @@clone_name)
    RepositorySupport.task = response

    assert_equal    202, response.code
    assert_includes response['call_request_tags'], 'pulp:action:associate'
  end

  def test_distribution_copy
    response = @@extension.distribution_copy(RepositorySupport.repo_id, @@clone_name)
    RepositorySupport.task = response

    assert_equal    202, response.code
    assert_includes response['call_request_tags'], 'pulp:action:associate'
  end
end


class TestExtensionsRepositoryUnassociate < MiniTest::Unit::TestCase

  @@extension = Runcible::Extensions::Repository
  @@clone_name = RepositorySupport.repo_id + "_clone"

  def self.before_suite
    VCR.insert_cassette('extensions/repository_dissassociate', :match_requests_on => [:method, :path, :params, :body_json])
    RepositorySupport.create_and_sync_repo(:importer => true)
    @@extension.create_with_importer(@@clone_name, {:id=>"yum_importer"})
    task = @@extension.unit_copy(@@clone_name, RepositorySupport.repo_id)
    RepositorySupport.wait_on_task(task)
  end

  def self.after_suite
    RepositorySupport.destroy_repo(@@clone_name)
    RepositorySupport.destroy_repo
    VCR.eject_cassette
  end

  def test_rpm_remove
    pkg_ids = RepositorySupport.rpm_ids
    refute_empty pkg_ids

    task = @@extension.rpm_remove(@@clone_name, [pkg_ids.first])
    RepositorySupport.wait_on_task(task)
    assert_equal (pkg_ids.length - 1), @@extension.rpm_ids(@@clone_name).length
  end

  def test_errata_remove
    errata_ids = @@extension.errata_ids(RepositorySupport.repo_id)
    refute_empty errata_ids
    task = @@extension.errata_remove(@@clone_name, [errata_ids.first])
    RepositorySupport.wait_on_task(task)
    assert_equal (errata_ids.length - 1), @@extension.errata_ids(@@clone_name).length
  end

  def test_distribution_remove
    dist_ids = @@extension.distributions(RepositorySupport.repo_id).collect{|d| d['id']}
    refute_empty dist_ids

    task = @@extension.distribution_remove(@@clone_name, dist_ids.first)
    RepositorySupport.wait_on_task(task)
    assert_equal (dist_ids.length - 1), @@extension.distributions(@@clone_name).length
  end

end
