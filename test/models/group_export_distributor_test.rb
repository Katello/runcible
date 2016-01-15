require 'rubygems'
require 'minitest/autorun'

require './lib/runcible'

class GroupExportDistributorTest < MiniTest::Unit::TestCase
  def setup
    @dist = Runcible::Models::GroupExportDistributor.new(true, true)
  end

  def test_config
    assert_equal(true, @dist.config["http"])
    assert_equal(true, @dist.config["https"])
    # NB: setting distributor_type_id and distributor_config saves a couple of API
    # calls when creating repos.
    assert_equal('group_export_distributor', @dist.config["distributor_type_id"])
    assert_equal({:http => true, :https => true}, @dist.config["distributor_config"])
  end

  def test_type_id
    assert_equal('group_export_distributor', @dist.type_id)
  end
end
