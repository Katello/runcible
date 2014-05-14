require 'rubygems'
require 'minitest/autorun'

require './lib/runcible'

module Extensions
  class TestExtensionsRpm < MiniTest::Unit::TestCase

    def setup
      @dist = Runcible::Models::YumCloneDistributor.new(:id=>"some_distributor_clone",
                                                               :destination_distributor_id => "Foo_dist")
    end

    def test_config
      assert_equal({:destination_distributor_id => "Foo_dist"}.as_json, @dist.config)
    end

    def test_type_id
        assert_equal('yum_clone_distributor', @dist.class.type_id)
    end

  end
end