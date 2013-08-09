# Copyright 2013 Red Hat, Inc.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'rubygems'
require 'minitest/autorun'

require './lib/runcible'
require './test/support/repository_support'

module TestContentBase

  def setup
    @resource = TestRuncible.server.resources.content
    VCR.insert_cassette('content')
  end

  def teardown
    VCR.eject_cassette
  end

end

class TestCreateUploadRequest < MiniTest::Unit::TestCase
  include TestContentBase

  def test_create_upload_request
    response = @resource.create_upload_request

    assert response.kind_of? Hash
    assert_equal 201, response.code
  end

end

class TestUploadBits < MiniTest::Unit::TestCase
  include TestContentBase

  def test_upload_bits
    VCR.use_cassette('content_upload') do
      test_request = @resource.create_upload_request
      response = @resource.upload_bits(test_request['upload_id'], '0', 'abcde')
      assert_equal 200, response.code
    end

  end

end

class TestImportIntoRepo < MiniTest::Unit::TestCase
  include TestContentBase

  def test_import_into_repo
    test_unit_key = {"checksumtype"=> "sha256", "checksum"=> "5e9fb809128d23a3e25d0c5fd38dd5d37d4ebceae7c6af8f15fed93e39d3145f",
                     "epoch"=> "0", "version"=> "8.3.3", "release"=> "1.elfake", "arch"=> "noarch", "name"=> "recons"}

    @@repo_support = RepositorySupport.new
    @@repo_support.create_and_sync_repo(:importer_and_distributor => true)
    response = @resource.import_into_repo(RepositorySupport.repo_id, 'rpm', 'uvwx', test_unit_key)

    assert_equal 200, response.code

  ensure
    @@repo_support.destroy_repo

  end

end

class TestDeleteUploadRequest < MiniTest::Unit::TestCase
  include TestContentBase

  def test_delete_upload_request
    VCR.use_cassette('content_delete') do
      test_request = @resource.create_upload_request
      response = @resource.delete_upload_request(test_request['upload_id'])
      assert_equal 200, response.code
    end
  end

end

class TestListAllUploadRequests < MiniTest::Unit::TestCase
  include TestContentBase

  def test_list_all_requests
    response = @resource.list_all_requests

    assert_equal 200, response.code
  end

end

