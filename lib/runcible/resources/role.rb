module Runcible
  module Resources
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/rest-api/role/index.html
    class Role < Runcible::Base
      # Generates the API path for Roles
      #
      # @param  [String]  id  the ID of the role
      # @return [String]      the role path, may contain the ID if passed
      def self.path(id = nil)
        id.nil? ? 'roles/' : "roles/#{id}/"
      end

      # Adds a user to a role
      #
      # @param  [String]                id    the ID of the role
      # @param  [String]                login the login of the user being added
      # @return [RestClient::Response]
      def add(id, login)
        required = required_params(binding.send(:local_variables), binding, ['id'])
        call(:post, "#{path(id)}users/", :payload => { :required => required })
      end

      # Removes a user from a role
      #
      # @param  [String]                id    the ID of the role
      # @param  [String]                login the login of the user being removed
      # @return [RestClient::Response]
      def remove(id, login)
        call(:delete, "#{path(id)}users/#{login}/")
      end
    end
  end
end
