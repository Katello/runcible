require 'rubygems'
require 'minitest/autorun'

require './lib/runcible'
require './test/support/repository_support'


class TestExtenionsPackageGroup < MiniTest::Unit::TestCase

  def self.before_suite
    @@extension = Runcible::Extensions::PackageGroup
    VCR.insert_cassette('extensions/package_group', :match_requests_on => [:method, :path, :params, :body_json])
    RepositorySupport.create_and_sync_repo(:importer => true)
  end

  def self.after_suite
    RepositorySupport.destroy_repo
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
