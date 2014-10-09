# Copyright 2014 Red Hat, Inc.
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

module Extensions
  module TestDockerRepositoryBase
    def setup
      @support = RepositorySupport.new('docker')
      @extension = TestRuncible.server.extensions.repository
    end
  end

  class TestDockerRepositoryCreate < MiniTest::Unit::TestCase
    include TestDockerRepositoryBase

    def teardown
      @support.destroy_repo
      super
    end

    def test_create_with_importer
      response = @extension.create_with_importer(RepositorySupport.repo_id, :id => 'docker_importer')
      assert_equal 201, response.code
      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'docker_importer', response['importers'].first['importer_type_id']
    end

    def test_create_with_importer_object
      response = @extension.create_with_importer(RepositorySupport.repo_id,
                                                 Runcible::Models::DockerImporter.new(:feed => 'https://index.docker.io',
                                                                                      :upstream_name => 'busybox'))
      assert_equal 201, response.code
      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'docker_importer', response['importers'].first['importer_type_id']

      @extension.expects(:create).with(RepositorySupport.repo_id, has_entry(:notes, anything)).returns(true)
      @extension.create_with_importer(RepositorySupport.repo_id, Runcible::Models::DockerImporter.new)
    end

    def test_create_with_distributors
      distributors = [{'type_id' => 'docker_distributor_web', 'id' => '123', 'auto_publish' => true,
                       'config' => {'docker_publish_directory' => '/path'}}]
      response = @extension.create_with_distributors(RepositorySupport.repo_id, distributors)

      assert_equal 201, response.code
      assert_equal RepositorySupport.repo_id, response['id']
    end

    def test_create_with_distributor_object
      repo_id = RepositorySupport.repo_id + '_distro'
      response = @extension.create_with_distributors(repo_id, [Runcible::Models::DockerDistributor.new(:docker_publish_directory => '/path',
                                                                                                       :id => '123')])
      assert_equal 201, response.code
      response = @extension.retrieve(repo_id, :details => true)
      assert_equal repo_id, response['id']
      assert_equal 'docker_distributor_web', response['distributors'].first['distributor_type_id']
    ensure
      @support.destroy_repo(repo_id)
    end

    def test_create_with_importer_and_distributors
      distributors = [{'type_id' => 'docker_distributor_web', 'id' => '123', 'auto_publish' => true,
                       'config' => {}}]
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id, {:id => 'docker_importer'}, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'docker_distributor_web', response['distributors'].first['distributor_type_id']
    end

    def test_create_with_importer_and_distributors_objects
      distributors = [Runcible::Models::DockerDistributor.new(:id => '123')]
      importer = Runcible::Models::DockerImporter.new
      response = @extension.create_with_importer_and_distributors(RepositorySupport.repo_id, importer, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(RepositorySupport.repo_id, :details => true)
      assert_equal RepositorySupport.repo_id, response['id']
      assert_equal 'docker_importer', response['importers'].first['importer_type_id']
    end
  end
end
