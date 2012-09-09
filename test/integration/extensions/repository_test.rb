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

require './test/integration/resources/helpers/repository_helper'
require './lib/runcible/extensions/repository'


module TestPulpRepositoryBase
  include RepositoryHelper

  def setup
    @extension = Runcible::Pulp::RepositoryExtensions
    VCR.insert_cassette('extensions/pulp_repository_extensions')
  end

  def teardown
    VCR.eject_cassette
  end

end

class TestPulpRepository < MiniTest::Unit::TestCase
  include TestPulpRepositoryBase
  
  def self.before_suite
    RepositoryHelper.create_repo
  end

  def self.after_suite
    RepositoryHelper.destroy_repo
  end

  def test_search_by_repository_ids
    response = @extension.search_by_repository_ids([RepositoryHelper.repo_id])
    assert response[:response_code] == 200
    assert response[:data].collect{ |repo| repo["display_name"] == RepositoryHelper.repo_id }.length > 0
  end

end
