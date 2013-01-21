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
require 'minitest/mock'
require './lib/runcible'
require './test/support/repository_support'

class UnitCopyBase < MiniTest::Unit::TestCase
  def self.clone_name
    RepositorySupport.repo_id + "_clone"
  end

  def self.before_suite
    if respond_to?(:extension_class)
      VCR.insert_cassette("extensions/#{extension_class.content_type}_repository_associate")
      RepositorySupport.destroy_repo(clone_name)
      RepositorySupport.destroy_repo
      RepositorySupport.create_and_sync_repo(:importer => true)
      Runcible::Extensions::Repository.create_with_importer(clone_name, {:id=>"yum_importer"})
    end
  end

  def self.after_suite
    if respond_to?(:extension_class)
      RepositorySupport.destroy_repo(clone_name)
      RepositorySupport.destroy_repo
      VCR.eject_cassette
    end
  end
  def test_copy
    if self.class.respond_to?(:extension_class)
      response = self.class.extension_class.copy(RepositorySupport.repo_id, self.class.clone_name)
      RepositorySupport.task = response

      assert_equal    202, response.code
      assert_includes response['call_request_tags'], 'pulp:action:associate'
    end
  end
end


class UnitUnassociateBase < MiniTest::Unit::TestCase
  def self.clone_name
    RepositorySupport.repo_id + "_clone"
  end

  def self.before_suite
    if respond_to?(:extension_class)
      VCR.insert_cassette("extensions/#{extension_class.content_type}_repository_unassociate",
                          :match_requests_on => [:method, :path, :params, :body_json])
      RepositorySupport.create_and_sync_repo(:importer => true)
      Runcible::Extensions::Repository.create_with_importer(clone_name, {:id=>"yum_importer"})
      task = Runcible::Extensions::Repository.unit_copy(clone_name, RepositorySupport.repo_id)
      RepositorySupport.wait_on_task(task)
    end
  end

  def self.after_suite
    if respond_to?(:extension_class)
      RepositorySupport.destroy_repo(clone_name)
      RepositorySupport.destroy_repo
      VCR.eject_cassette
    end
  end

  def content_ids(repo)
    groups = units(repo)
    groups.collect{|i| i['metadata']['id']}
  end

  def units(repo)
    Runcible::Extensions::Repository.unit_search(repo,
    :type_ids=>[self.class.extension_class.content_type])
  end

  def unit_ids(repo)
    units(repo).collect {|i| i['unit_id']}
  end

  def test_unassociate_by_id
    if respond_to?(:extension_class)
      ids = content_ids(RepositorySupport.repo_id)
      refute_empty ids
      task = self.class.extension_class.unassociate_ids_from_repo(self.class.clone_name, [ids.first])
      RepositorySupport.wait_on_task(task)
      assert_equal (ids.length - 1), content_ids(self.class.clone_name).length
    end
  end

  def test_unassociate_by_unit_id
    if respond_to?(:extension_class)
      ids = unit_ids(RepositorySupport.repo_id)
      refute_empty ids
      task = self.class.extension_class.unassociate_unit_ids_from_repo(self.class.clone_name, [ids.first])
      RepositorySupport.wait_on_task(task)
      assert_equal (ids.length - 1), unit_ids(self.class.clone_name).length
    end
  end

end