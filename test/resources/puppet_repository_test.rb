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

module Resources
  module TestPuppetRepositoryBase
    def setup
      @resource = TestRuncible.server.resources.repository
      @extension = TestRuncible.server.extensions.repository
      @support = RepositorySupport.new
    end
  end

  class TestPuppetRepositoryRequiresSync < MiniTest::Unit::TestCase
    include TestPuppetRepositoryBase

    def setup
      super
      @support.create_and_sync_repo(:importer_and_distributor => true)
    end

    def teardown
      @support.destroy_repo
      super
    end

    def test_publish
      response = @resource.publish(RepositorySupport.repo_id, @support.distributor['id'])
      tasks = assert_async_response(response)

      assert_includes tasks.first['tags'], 'pulp:action:publish'
    end

    def test_unassociate_units
      response = @resource.unassociate_units(RepositorySupport.repo_id, {})
      assert_async_response(response)
    end

    def test_unit_search
      response = @resource.unit_search(RepositorySupport.repo_id, {})

      assert_equal 200, response.code
      refute_empty response
    end

    def test_sync_history
      response = @resource.sync_history(RepositorySupport.repo_id)

      assert 200, response.code
      refute_empty response
    end
  end
end
