require 'rubygems'
require 'minitest/autorun'

require './lib/runcible'

class PuppetDistributorTest < MiniTest::Unit::TestCase

  def setup
    @dist = Runcible::Models::PuppetDistributor.new(:id => "puppet_distirubtor",
                                                    :http => "http://example.com",
                                                    :https => "https://example.com"
                                                   )
  end

  def test_config
    config = {"serve_http" => "http://example.com", "serve_https" => "https://example.com"}
    assert_equal config, @dist.config
  end

  def test_type_id
    assert_equal('puppet_distributor', @dist.type_id)
  end

end
