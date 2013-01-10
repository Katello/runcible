require 'rubygems'
require 'minitest/autorun'

require './lib/runcible'
require './test/support/repository_support'


class TestExtenionsRpm < MiniTest::Unit::TestCase

  def self.before_suite
    @@extension = Runcible::Extensions::Rpm
    VCR.insert_cassette('extensions/rpm', :match_requests_on => [:method, :path, :params, :body_json])
    RepositorySupport.create_and_sync_repo(:importer => true)
  end

  def self.after_suite
    RepositorySupport.destroy_repo
    VCR.eject_cassette
  end

  def test_content_type
    assert_equal 'rpm', @@extension.content_type
  end

  def test_all
    response = @@extension.all

    assert_equal 200, response.code
    refute_empty response
  end

  def test_find
    assert_raises(NotImplementedError) { response = @@extension.find }
  end

  def test_find_all
    assert_raises(NotImplementedError) { response = @@extension.find_all }
  end

  def test_find_by_unit_id
    id = @@extension.all.sort_by{|p| p['_id']}.first['_id']
    response = @@extension.find_by_unit_id(id)

    refute_empty response
    assert_equal id, response['_id']
  end

  def test_find_unknown
    response = @@extension.find_all_by_unit_ids(['f'])

    assert_empty response
  end

  def test_find_all_by_unit_ids
    pkgs = @@extension.all.sort_by{|p| p['_id']}
    ids = pkgs[0..2].collect{|p| p['_id']}
    response = @@extension.find_all_by_unit_ids(ids)

    assert_equal 200, response.code
    assert_equal ids.length, response.length
  end

end
