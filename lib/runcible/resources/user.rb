module Runcible
  module Resources
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/rest-api/user/index.html
    class User < Runcible::Base
      # Generates the API path for Users
      #
      # @param  [String]  login the user's login
      # @return [String]        the user path, may contain the login if passed
      def self.path(login = nil)
        login.nil? ? 'users/' : "users/#{login}/"
      end

      # Retrieves all users
      #
      # @return [RestClient::Response]
      def retrieve_all
        call(:get, path)
      end

      # Creates a user
      #
      # @param  [String]                login     the login requested for the user
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def create(login, optional = {})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path, :payload => { :required => required, :optional => optional })
      end

      # Retrieves a user
      #
      # @param  [String]                login the login of the user being retrieved
      # @return [RestClient::Response]
      def retrieve(login)
        call(:get, path(login))
      end

      # Deletes a user
      #
      # @param  [String]                login the login of the user being deleted
      # @return [RestClient::Response]
      def delete(login)
        call(:delete, path(login))
      end
    end
  end
end
