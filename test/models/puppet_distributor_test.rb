require 'rubygems'
require 'minitest/autorun'

require './lib/runcible'

class PuppetDistributorTest < MiniTest::Unit::TestCase
  def setup
    @dist = Runcible::Models::PuppetDistributor.new('/some/path/testing/', true, true)
  end

  def test_config
    config = {'absolute_path' => '/some/path/testing/', 'serve_http' => true, 'serve_https' => true}
    assert_equal config, @dist.config
  end

  def test_type_id
    assert_equal('puppet_distributor', @dist.type_id)
  end
end
