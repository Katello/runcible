require 'rubygems'
require 'minitest/autorun'

require './lib/runcible'
require './test/extensions/unit_base'
require './test/support/repository_support'

module Extensions
  class TestDrpm < MiniTest::Unit::TestCase
    def self.before_suite
      @@extension = TestRuncible.server.extensions.drpm
    end

    def test_content_type
      assert_equal 'drpm', @@extension.content_type
    end

    def test_find
      assert_raises(NotImplementedError) { @@extension.find }
    end

    def test_find_all
      assert_raises(NotImplementedError) { @@extension.find_all }
    end
  end
end
