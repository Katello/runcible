require 'rubygems'
require 'minitest/autorun'

require './lib/runcible'

class PuppetInstallDistributorTest < MiniTest::Unit::TestCase
  def setup
    @dist = Runcible::Models::PuppetInstallDistributor.new('/etc/puppet')
  end

  def test_config
    config = {'install_path' => '/etc/puppet', 'auto_publish' => false}
    assert_equal config, @dist.config
  end

  def test_type_id
    assert_equal('puppet_install_distributor', @dist.type_id)
  end
end
