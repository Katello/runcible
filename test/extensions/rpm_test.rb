require 'rubygems'
require 'minitest/autorun'

require './lib/runcible'
require './test/extensions/unit_base'
require './test/support/repository_support'


class TestExtensionsRpm < MiniTest::Unit::TestCase

  def self.before_suite
    @@support = RepositorySupport.new
    @@extension = TestRuncible.server.extensions.rpm
    VCR.insert_cassette('extensions/rpm', :match_requests_on => [:method, :path, :params, :body_json])
    @@support.create_and_sync_repo(:importer => true)
  end

  def self.after_suite
    @@support.destroy_repo
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

class TestExtensionsRpmCopy < UnitCopyBase

  def self.extension_class
    TestRuncible.server.extensions.rpm
  end

  def test_copy
    response = self.class.extension_class.copy(RepositorySupport.repo_id, self.class.clone_name)
    @@support.task = response

    assert_equal    202, response.code
    assert_includes response['call_request_tags'], 'pulp:action:associate'
  end

  def test_copy_with_filters
    response = Runcible::Extensions::Rpm.copy(RepositorySupport.repo_id,
                                 self.class.clone_name,
                                 :filters => {
                                      :unit => {
                                        "$and" => [{'name' => {'$regex' => 'p.*'}},
                                            {'version'=> {'$gt'=> '1.0'}}]
                                        }}
                                 )
    RepositorySupport.task = response

    assert_equal    202, response.code
    assert_includes response['call_request_tags'], 'pulp:action:associate'
  end
end

class TestExtensionsRpmUnassociate < UnitUnassociateBase

  def self.extension_class
    TestRuncible.server.extensions.rpm
  end

  def setup
    task = TestRuncible.server.extensions.repository.unit_copy(self.class.clone_name, RepositorySupport.repo_id)
    @@support.wait_on_task(task)
  end

  def test_unassociate_ids_from_repo
    ids = content_ids(RepositorySupport.repo_id)
    refute_empty ids
    assert_raises(NotImplementedError) do
      self.class.extension_class.unassociate_ids_from_repo(self.class.clone_name, [ids.first])
    end
  end

  def test_unassociate_unit_ids_from_repo
    ids = unit_ids(self.class.clone_name)
    refute_empty ids
    task = self.class.extension_class.unassociate_unit_ids_from_repo(self.class.clone_name, [ids.first])
    @@support.wait_on_task(task)
    assert_equal (ids.length - 1), unit_ids(self.class.clone_name).length
  end

  def test_unassociate_from_repo
    ids = unit_ids(self.class.clone_name)
    refute_empty ids
    task = self.class.extension_class.unassociate_from_repo(self.class.clone_name,
                                                            :association => {'unit_id' => {'$in' => [ids.first]}})
    @@support.wait_on_task(task)
    assert_equal (ids.length - 1), unit_ids(self.class.clone_name).length
  end

end
