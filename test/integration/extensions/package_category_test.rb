require 'rubygems'
require 'minitest/autorun'

require './lib/runcible'
require './test/integration/resources/helpers/repository_helper'


class TestExtenionsPackageGroup < MiniTest::Unit::TestCase

  def self.before_suite
    @@extension = Runcible::Extensions::PackageCategory
    VCR.insert_cassette('extensions/package_category', :match_requests_on => [:method, :uri, :body])
    RepositoryHelper.create_and_sync_repo(:importer => true)
  end

  def self.after_suite
    RepositoryHelper.destroy_repo
    VCR.eject_cassette
  end

  def test_all
    response = @@extension.all

    assert response.code == 200
    assert !response.empty?
  end

  def test_find
    id = @@extension.all.sort_by{|p| p['id']}.first['id']
    response = @@extension.find(id)
    assert !response.empty?
    assert response['id'] == id
  end

  def test_find_unknown
    response = @@extension.find_all(['f'])
    assert response.empty?

  end

  def test_find_all
    pkgs = @@extension.all.sort_by{|p| p['id']}
    ids = pkgs[0..2].collect{|p| p['id']}
    response = @@extension.find_all(ids)
    assert response.code == 200
    assert response.length == ids.length
  end

  def test_find_all_by_unit_ids
    id = @@extension.all.sort_by{|p| p['id']}.first['_id']
    response = @@extension.find_all_by_unit_ids([id])
    assert !response.empty?
    assert response.first['_id'] == id
  end

end
