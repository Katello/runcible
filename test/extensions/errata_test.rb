# Copyright (c) 2012 Red Hat
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

require './lib/runcible'
require './test/extensions/unit_base'
require './test/support/repository_support'


class TestExtensionsErrata < MiniTest::Unit::TestCase

  def self.before_suite
    @@extension = Runcible::Extensions::Errata
    VCR.insert_cassette('extensions/errata', :match_requests_on => [:method, :path, :params, :body_json])
    RepositorySupport.create_and_sync_repo(:importer => true)
  end

  def self.after_suite
    RepositorySupport.destroy_repo
    VCR.eject_cassette
  end

  def test_all
    response = @@extension.all

    assert_equal 200, response.code
    refute_empty response
  end

  def test_find
    id = @@extension.all.sort_by{|p| p['id']}.first['id']
    response = @@extension.find(id)
    
    refute_empty response
    assert_equal id, response['id']
  end

  def test_find_by_unit_id
    id = @@extension.all.sort_by{|p| p['id']}.first['_id']
    response = @@extension.find_by_unit_id(id)
    
    refute_empty response
    assert_equal id, response['_id']
  end

  def test_find_unknown
    response = @@extension.find_all(['f'])
    
    assert_empty response
  end

  def test_find_all_by_unit_ids
    id = @@extension.all.sort_by{|p| p['_id']}.first['_id']
    response = @@extension.find_all_by_unit_ids([id])

    refute_empty response
    assert_equal id, response.first['_id']
  end

  def test_find_all
    pkgs = @@extension.all.sort_by{|p| p['id']}
    ids = pkgs[0..2].collect{|p| p['id']}
    response = @@extension.find_all(ids)

    assert_equal 200, response.code
    assert_equal ids.length, response.length
  end

end

class TestExtensionsErrataCopy < UnitCopyBase
  def self.extension_class
    Runcible::Extensions::Errata
  end

  def test_copy
    response = Runcible::Extensions::Errata.copy(RepositorySupport.repo_id, self.class.clone_name)
    RepositorySupport.task = response

    assert_equal    202, response.code
    assert_includes response['call_request_tags'], 'pulp:action:associate'
  end
end

class TestExtensionsErrataUnassociate < UnitUnassociateBase

  def self.extension_class
    Runcible::Extensions::Errata
  end

  def setup
    task = Runcible::Extensions::Repository.unit_copy(self.class.clone_name, RepositorySupport.repo_id)
    RepositorySupport.wait_on_task(task)
  end

  def test_unassociate_ids_from_repo
    ids = content_ids(RepositorySupport.repo_id)
    refute_empty ids
    task = Runcible::Extensions::Errata.unassociate_ids_from_repo(self.class.clone_name, [ids.first])
    RepositorySupport.wait_on_task(task)
    assert_equal (ids.length - 1), content_ids(self.class.clone_name).length
  end

  def test_unassociate_unit_ids_from_repo
    ids = unit_ids(RepositorySupport.repo_id)
    refute_empty ids
    task = Runcible::Extensions::Errata.unassociate_unit_ids_from_repo(self.class.clone_name, [ids.first])
    RepositorySupport.wait_on_task(task)
    assert_equal (ids.length - 1), unit_ids(self.class.clone_name).length
  end


  def test_unassociate_from_repo
    ids = unit_ids(RepositorySupport.repo_id)
    refute_empty ids
    task = Runcible::Extensions::Errata.unassociate_from_repo(self.class.clone_name,
                                                            :association => {'unit_id' => {'$in' => [ids.first]}})
    RepositorySupport.wait_on_task(task)
    assert_equal (ids.length - 1), unit_ids(self.class.clone_name).length
  end

end
