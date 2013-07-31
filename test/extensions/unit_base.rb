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
    @@support = RepositorySupport.new
    if respond_to?(:extension_class)
      VCR.insert_cassette("extensions/#{extension_class.class.content_type}_repository_associate")
      @@support.destroy_repo(clone_name)
      @@support.destroy_repo
      @@support.create_and_sync_repo(:importer => true)
      TestRuncible.server.extensions.repository.create_with_importer(clone_name, {:id=>"yum_importer"})
    end
  end

  def self.after_suite
    if respond_to?(:extension_class)
      @@support.destroy_repo(clone_name)
      @@support.destroy_repo
      VCR.eject_cassette
    end
  end

  def units(repo)
    TestRuncible.server.extensions.repository.unit_search(repo,
    :type_ids=>[self.class.extension_class.class.content_type])
  end

  def unit_ids(repo)
    units(repo).collect {|i| i['unit_id']}
  end

end


class UnitUnassociateBase < MiniTest::Unit::TestCase
  def self.clone_name
    RepositorySupport.repo_id + "_clone"
  end

  def self.before_suite
    @@support = RepositorySupport.new
    if respond_to?(:extension_class)
      VCR.insert_cassette("extensions/#{extension_class.content_type}_repository_unassociate",
                          :match_requests_on => [:method, :path, :params, :body_json])
      @@support.create_and_sync_repo(:importer => true)
      TestRuncible.server.extensions.repository.create_with_importer(clone_name, {:id=>"yum_importer"})
    end
  end

  def self.after_suite
    if respond_to?(:extension_class)
      @@support.destroy_repo(clone_name)
      @@support.destroy_repo
      VCR.eject_cassette
    end
  end

  def content_ids(repo)
    groups = units(repo)
    groups.collect{|i| i['metadata']['id']}
  end

  def units(repo)
    TestRuncible.server.extensions.repository.unit_search(repo,
    :type_ids=>[self.class.extension_class.content_type])
  end

  def unit_ids(repo)
    units(repo).collect {|i| i['unit_id']}
  end

end
