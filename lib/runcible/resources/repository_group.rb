require 'active_support/core_ext/hash'

module Runcible
  module Resources
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/integration/rest-api/repo/groups/
    class RepositoryGroup < Runcible::Base
      # Generates the API path for Repository Groups
      #
      # @param  [String]  id  the ID of the Repository group
      # @return [String]      the Repository group path, may contain the id if passed
      def self.path(id = nil)
        groups = 'repo_groups/'
        id.nil? ? groups : groups + "#{id}/"
      end

      # Creates a Repository Group
      #
      # @param  [String]                id        the ID of the group
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def create(id, optional = {})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path, :payload => { :required => required, :optional => optional })
      end

      # Retrieves a Repository Group
      #
      # @param  [String]                id  the ID of the Repository group
      # @return [RestClient::Response]
      def retrieve(id)
        call(:get, path(id))
      end

      # Retrieves a Repository Group's distributors
      #
      # @param  [String]                id  the ID of the Repository group
      # @return [RestClient::Response]
      def retrieve_distributors(id)
        call(:get, path(id) + 'distributors/')
      end

      # Retrieves all Repository Group
      #
      # @return [RestClient::Response]
      def retrieve_all
        call(:get, path)
      end

      # Deletes a Repository Group
      #
      # @param  [String]                id  the ID of the Repository group
      # @return [RestClient::Response]
      def delete(id)
        call(:delete, path(id))
      end

      # Associates Repositories with a Repository Group
      #
      # @param  [String]                id        the ID of the Repository group
      # @param  [Hash]                  criteria  criteria based on Mongo syntax representing repos to associate
      # @return [RestClient::Response]
      def associate(id, criteria)
        call(:post, path(id) + 'actions/associate/', :payload => {:required => criteria})
      end

      # Unassociates Repositories with a Repository Group
      #
      # @param  [String]                id        the ID of the Repository group
      # @param  [Hash]                  criteria  criteria based on Mongo syntax representing repos ta unassociate
      # @return [RestClient::Response]
      def unassociate(id, criteria)
        call(:post, path(id) + 'actions/unassociate/', :payload => {:required => criteria})
      end

      # Publishes a repository group using the specified distributor
      #
      # @param  [String]                id              the id of the repository
      # @param  [String]                distributor_id  the id of the distributor
      # @param  [Hash]                  optional  optional params
      # @return [RestClient::Response]
      def publish(id, distributor_id, optional = {})
        call(:post, "#{path(id)}actions/publish/",
             :payload => {:required => {:id => distributor_id}, :optional => optional})
      end


    end
  end
end
