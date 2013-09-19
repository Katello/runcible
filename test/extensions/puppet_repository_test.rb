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


module TestExtensionsPuppetRepositoryBase

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

class TestExtensionsPuppetRepositoryCreate < MiniTest::Unit::TestCase
  include TestExtensionsPuppetRepositoryBase

  def teardown
    super
    @support.destroy_repo
  end

  def test_create_with_importer
    VCR.use_cassette('extensions/puppet_repository_create_with_importer') do
      response = @extension.create_with_importer(RepositorySupport.repo_id, {:id=>"puppet_importer"})
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, {:details => true})
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal "puppet_importer", response['importers'].first['importer_type_id']
    end
  end

  def test_create_with_importer_object
    VCR.use_cassette('extensions/puppet_repository_create_with_importer') do
      response = @extension.create_with_importer(RepositorySupport.repo_id, Runcible::Models::PuppetImporter.new())
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, {:details => true})
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal "puppet_importer", response['importers'].first['importer_type_id']

      @extension.expects(:create).with(RepositorySupport.repo_id, has_entry(:notes, anything)).returns(true)
      @extension.create_with_importer(RepositorySupport.repo_id, Runcible::Models::PuppetImporter.new())
    end

  end

  def test_create_with_distributors
    VCR.use_cassette('extensions/puppet_repository_create_with_distributors_hash') do

      distributors = [{'type_id' => 'puppet_distributor', 'id'=>'123', 'auto_publish'=>true,
                       'config'=>{'relative_url' => '/path', 'http' => true, 'https' => true}}]
      response = @extension.create_with_distributors(RepositorySupport.repo_id, distributors)

      assert_equal 201, response.code
      assert_equal RepositorySupport.repo_id, response['id']
    end
  end

  def test_create_with_distributor_object
    VCR.use_cassette('extensions/puppet_repository_create_with_distributors') do
        begin
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
    end

  end

  def test_create_with_importer_and_distributors
    VCR.use_cassette('extensions/puppet_repository_create_with_importers_distributors') do
      distributors = [{'type_id' => 'puppet_distributor', 'id'=>'123', 'auto_publish'=>true,
                       'config'=>{'relative_url' => '/', 'http' => true, 'https' => true}}]
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id, {:id=>'puppet_importer'}, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, {:details => true})
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'puppet_distributor', response['distributors'].first['distributor_type_id']
    end
  end

  def test_create_with_importer_and_distributors_objects
    VCR.use_cassette('extensions/puppet_repository_create_with_importers_distributors') do

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


end

