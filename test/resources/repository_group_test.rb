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
require './lib/runcible/resources/repository_group'
require './lib/runcible/resources/repository'
require './test/support/repository_support'


module TestRepoGroupBase
  include RepositorySupport

  def setup
    @resource = Runcible::Resources::RepositoryGroup
    @repo_group_id = "integration_test_repository_group"
    VCR.insert_cassette('repository_group')
  end

  def teardown
    VCR.eject_cassette
  end

  def create_repo_group
    @resource.create(@repo_group_id, :display_name => "foo", :description => 'Test description.')
  rescue Exception => e
  end

  def destroy_repo_group
    @resource.delete(@repo_group_id)
  rescue Exception => e
  end

end


class TestRepoGroupCreate < MiniTest::Unit::TestCase
  include TestRepoGroupBase

  def teardown
    destroy_repo_group
    super
  end

  def test_create
    response = create_repo_group
    assert_equal @repo_group_id, response['id']
  end

end


class TestRepoGroup < MiniTest::Unit::TestCase
  include TestRepoGroupBase

  def teardown
    destroy_repo_group
    super
  end

  def setup
    super
    create_repo_group
  end

  def test_retrieve
   response = @resource.retrieve(@repo_group_id)
   assert_equal @repo_group_id, response['id']
  end

  def test_retrieve_all
    response = @resource.retrieve_all
    refute_empty response
    assert_equal 1, response.select{|grp| grp[:id] == @repo_group_id}.size
  end
end


class TestRepoGroupDestroy < MiniTest::Unit::TestCase
  include TestRepoGroupBase

  def setup
    super
    create_repo_group
  end

  def test_destroy
    response = @resource.delete(@repo_group_id)
    assert_equal 200, response.code
  end

end


class TestRepoGroupAssociate < MiniTest::Unit::TestCase
  include TestRepoGroupBase

  def setup
    super
    create_repo_group
    RepositorySupport.create_repo
    @repo_id = RepositorySupport.repo_id
  end

  def teardown
    destroy_repo_group
    RepositorySupport.destroy_repo
    super
  end

  def test_associate
    @criteria = {:criteria =>
                   {:filters =>
                     {:id =>
                        {"$in" => [@repo_id]}
                     }
                   }
                }
    response = @resource.associate(@repo_group_id, @criteria)

    assert_equal    200, response.code
    assert_includes response, @repo_id
  end
end


class TestRepoGroupUnassociate < MiniTest::Unit::TestCase
  include TestRepoGroupBase

  def setup
    super
    create_repo_group
    RepositorySupport.create_repo
    @repo_id = RepositorySupport.repo_id
    @criteria = {:criteria =>
                   {:filters =>
                     {:id =>
                        {"$in" => [@repo_id]}
                     }
                   }
                }
    @resource.associate(@repo_group_id, @criteria)
  end

  def teardown
    destroy_repo_group
    RepositorySupport.destroy_repo
    super
  end

  def test_unassociate
    response = @resource.unassociate(@repo_group_id, @criteria)

    assert_equal    200, response.code
    refute_includes response, @repo_id
  end
end
