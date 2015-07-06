require 'rubygems'
require 'minitest/autorun'

module Resources
  module TestUserBase
    def setup
      @username = 'integration_test_user'
      @resource = TestRuncible.server.resources.user
    end
  end

  class TestUserCreate < MiniTest::Unit::TestCase
    include TestUserBase

    def teardown
      @resource.delete(@username)
    ensure
      super
    end

    def test_create
      response = @resource.create(@username)

      assert_equal 201, response.code
      assert_equal @username, response['login']
    end

    def test_create_with_name_and_password
      response = @resource.create(@username, :name => @username, :password => 'integration_test_password')

      assert_equal 201, response.code
      assert_equal @username, response['name']
    end
  end

  class TestUser < MiniTest::Unit::TestCase
    include TestUserBase

    def setup
      super
      begin
        @resource.retrieve(@username)
      rescue RestClient::ResourceNotFound
        @resource.create(@username)
      end
    end

    def teardown
      @resource.delete(@username)
    rescue RestClient::ResourceNotFound => e
      puts "Could not destroy user #{@username}. Exception \n #{e}"
    ensure
      super
    end

    def test_path
      path = @resource.class.path

      assert_match 'users/', path
    end

    def test_path_with_username
      path = @resource.class.path(@username)

      assert_match "users/#{@username}", path
    end

    def test_retrieve
      response = @resource.retrieve(@username)

      assert_equal 200, response.code
      assert_equal @username, response['login']
    end

    def test_retrieve_all
      response = @resource.retrieve_all

      assert_equal 200, response.code
      refute_empty response
    end

    def test_delete
      response = @resource.delete(@username)

      assert_equal 200, response.code
    end
  end
end
