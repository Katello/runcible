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

module Extensions
  module TestIsoRepositoryBase

    def setup
      @support = RepositorySupport.new
      @extension = TestRuncible.server.extensions.repository
    end

  end

  class TestIsoRepositoryCreate < MiniTest::Unit::TestCase
    include TestIsoRepositoryBase

    def setup
      super
      @repo_url = "file://#{File.expand_path(File.dirname(__FILE__))}".gsub("test/extensions", "test/fixtures/repositories/iso/")
      @repo_id = 'test_repo_iso_fixture'
    end

    def teardown
      @support.destroy_repo(@repo_id)
      super
    end

    def test_create_with_importer_and_distributors_objects
      distributors = [Runcible::Models::IsoDistributor.new(true, true)]
      importer = Runcible::Models::IsoImporter.new(:feed=>@repo_url)

      response = @extension.create_with_importer_and_distributors(@repo_id, importer, distributors)
      assert_equal 201, response.code

      response = @extension.retrieve(@repo_id, {:details => true})
      assert_equal @repo_id, response['id']
      assert_equal "iso_importer", response['importers'].first['importer_type_id']

      response = @extension.sync(@repo_id)
      assert_async_response(response)

      response = @extension.sync_history(@repo_id)
      assert_equal 'success', response.first['result']
    end
  end
end