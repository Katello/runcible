# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'rubygems'
require 'minitest/autorun'
require './lib/runcible/resources/consumer'
require './lib/runcible/extensions/consumer'
require './test/integration/resources/helpers/repository_helper'
require 'active_support/core_ext/time/calculations'


class TestConsumer < MiniTest::Unit::TestCase

  def setup
    @resource = Runcible::Resources::Consumer
    @extension = Runcible::Extensions::Consumer
    @consumer_id = "integration_test_consumer_extensions11000"
    VCR.insert_cassette('extensions/consumer_extensions')
    create_consumer
    bind_repo
  end

  def teardown
    destroy_consumer
    VCR.eject_cassette
  end

  def create_consumer
    @resource.create(@consumer_id, :name=>"boo")
  end

  def destroy_consumer
    @resource.delete(@consumer_id)
  end

  def bind_repo
    @extension.bind_all(@consumer_id, RepositoryHelper.repo_id)
  end

  def self.before_suite
    RepositoryHelper.create_and_sync_repo(:importer_and_distributor => true)
  end

  def self.after_suite
    RepositoryHelper.destroy_repo
  end

  def test_bind_all
    @extension.unbind_all(@consumer_id, RepositoryHelper.repo_id)
    assert(@resource.retrieve_bindings(@consumer_id).empty?)
    response = @extension.bind_all(@consumer_id, RepositoryHelper.repo_id)
    assert_equal(RepositoryHelper.repo_id, response.first[:repo_id])
    assert(!@resource.retrieve_bindings(@consumer_id).empty?)
  end

  def test_unbind_all
    assert(!@resource.retrieve_bindings(@consumer_id).empty?)
    response = @extension.unbind_all(@consumer_id, RepositoryHelper.repo_id)
    assert(@resource.retrieve_bindings(@consumer_id).empty?)
  end

end


