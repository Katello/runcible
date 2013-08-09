# Copyright 2013 Red Hat, Inc.
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

  def setup
    @support = RepositorySupport.new("puppet")
    @extension = TestRuncible.server.extensions.repository
    VCR.insert_cassette('extensions/puppet_repository',
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
    @support.destroy_repo
  end

  def test_create_with_importer
    response = @extension.create_with_importer(RepositorySupport.repo_id, {:id=>"puppet_importer"})
    assert_equal 201, response.code

    response = @extension.retrieve(RepositorySupport.repo_id, {:details => true})
    assert_equal RepositorySupport.repo_id, response['id']
    assert_equal "puppet_importer", response['importers'].first['importer_type_id']
  end

  def test_create_with_importer_object
    response = @extension.create_with_importer(RepositorySupport.repo_id, Runcible::Models::PuppetImporter.new())
    assert_equal 201, response.code

    response = @extension.retrieve(RepositorySupport.repo_id, {:details => true})
    assert_equal RepositorySupport.repo_id, response['id']
    assert_equal "puppet_importer", response['importers'].first['importer_type_id']
  end

  def test_create_with_distributors
    VCR.use_cassette('extensions/puppet_repository_create_with_importer') do

      distributors = [{'type_id' => 'puppet_distributor', 'id'=>'123', 'auto_publish'=>true,
                       'config'=>{'relative_url' => '/path', 'http' => true, 'https' => true}}]
      response = @extension.create_with_distributors(RepositorySupport.repo_id, distributors)

      assert_equal 201, response.code
      assert_equal RepositorySupport.repo_id, response['id']
    end
  end

  def test_create_with_distributor_object
    repo_id = RepositorySupport.repo_id + "_distro"
    response = @extension.create_with_distributors(repo_id, [Runcible::Models::PuppetDistributor.new(
        '/path', true, true, :id => '123')])
    assert_equal 201, response.code

    response = @extension.retrieve(repo_id, {:details => true})
    assert_equal repo_id, response['id']
    assert_equal 'puppet_distributor', response['distributors'].first['distributor_type_id']
  ensure
    @support.destroy_repo(repo_id)
  end

  def test_create_with_importer_and_distributors
    distributors = [{'type_id' => 'puppet_distributor', 'id'=>'123', 'auto_publish'=>true,
                     'config'=>{'relative_url' => '/', 'http' => true, 'https' => true}}]
    response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id, {:id=>'puppet_importer'}, distributors)
    assert_equal 201, response.code

    response = @extension.retrieve(RepositorySupport.repo_id, {:details => true})
    assert_equal RepositorySupport.repo_id, response['id']
    assert_equal 'puppet_distributor', response['distributors'].first['distributor_type_id']
  end

  def test_create_with_importer_and_distributors_objects
    distributors = [Runcible::Models::PuppetDistributor.new(
            '/path', true, true, :id => '123')]
    importer = Runcible::Models::PuppetImporter.new()
    response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id, importer, distributors)
    assert_equal 201, response.code

    response = @extension.retrieve(RepositorySupport.repo_id, {:details => true})
    assert_equal RepositorySupport.repo_id, response['id']
    assert_equal "puppet_importer", response['importers'].first['importer_type_id']
  end


end

class TestResourcesRepositoryRequiresSync < MiniTest::Unit::TestCase
  include TestResourcesRepositoryBase

  def setup
    super
    @support.create_and_sync_repo(:importer_and_distributor => true)
  end

  def teardown
    @support.destroy_repo
    super
  end

  def test_publish
    response = @resource.publish(RepositorySupport.repo_id, @support.distributor)
    @support.wait_on_task(response)

    assert_equal    202, response.code
    assert_includes response['call_request_tags'], 'pulp:action:publish'
  end

  def test_unassociate_units
    response = @resource.unassociate_units(RepositorySupport.repo_id, {})
    @support.wait_on_task(response)

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
    @support.create_and_sync_repo(:importer => true)
    @extension.create_with_importer(@clone_name, :id => "yum_importer")
  end

  def teardown
    @support.destroy_repo(@clone_name)
    @support.destroy_repo
    super
  end

  def test_unit_copy
    response = @resource.unit_copy(@clone_name, RepositorySupport.repo_id)
    @support.task = response

    assert_equal    202, response.code
    assert_includes response['call_request_tags'], 'pulp:action:associate'
  end

end
