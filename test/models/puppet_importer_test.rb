require 'rubygems'
require 'minitest/autorun'

require './lib/runcible'

class PuppetImporterTest < MiniTest::Unit::TestCase

  def setup
    @attrs = {"feed" => "http://forge.puppetlabs.com", "queries" => "apache"}
    @importer = Runcible::Models::PuppetImporter.new(@attrs)
  end

  def test_config
    assert_equal @attrs, @importer.config
  end

  def test_repo_type
    assert_equal Runcible::Models::PuppetImporter::REPO_TYPE, @importer.repo_type
  end

end
