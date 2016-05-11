module Runcible
  module Resources
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/rest-api/consumer/index.html
    class Consumer < Runcible::Base
      # Generates the API path for Consumers
      #
      # @param  [String]  id  the ID of the consumer
      # @return [String]      the consumer path, may contain the id if passed
      def self.path(id = nil)
        id.nil? ? 'consumers/' : "consumers/#{id}/"
      end

      # Creates a consumer
      #
      # @param  [String]                id        the ID of the consumer
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def create(id, optional = {})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path, :payload => { :required => required, :optional => optional })
      end

      # Retrieves a consumer
      #
      # @param  [String]                id  the ID of the consumer
      # @return [RestClient::Response]
      def retrieve(id)
        call(:get, path(id))
      end

      # Updates a consumer
      #
      # @param  [String]                id        the ID of the consumer
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def update(id, optional = {})
        call(:put, path(id), :payload => { :delta => optional })
      end

      # Deletes a consumer
      #
      # @param  [String]                id  the id of the consumer
      # @return [RestClient::Response]
      def delete(id)
        call(:delete, path(id))
      end

      # Create consumer profile
      #
      # @param  [String]                id            the ID of the consumer
      # @param  [String]                content_type  the content type
      # @param  [Hash]                  profile       hash representing the consumer profile
      # @return [RestClient::Response]
      def upload_profile(id, content_type, profile)
        required = required_params(binding.send(:local_variables), binding, ['id'])
        call(:post, path("#{id}/profiles/"), :payload => { :required => required })
      end

      # Retrieve a consumer profile
      #
      # @param  [String]                id            the ID of the consumer
      # @param  [String]                content_type  the content type
      # @return [RestClient::Response]
      def retrieve_profile(id, content_type)
        call(:get, path("#{id}/profiles/#{content_type}/"))
      end

      # Retrieve a consumer binding
      #
      # @param  [String]                id              the ID of the consumer
      # @param  [String]                repo_id         the ID of the repository
      # @param  [String]                distributor_id  the ID of the distributor
      # @return [RestClient::Response]
      def retrieve_binding(id, repo_id, distributor_id)
        call(:get, path("#{id}/bindings/#{repo_id}/#{distributor_id}"))
      end

      # Retrieve all consumer bindings
      #
      # @param  [String]                id  the ID of the consumer
      # @return [RestClient::Response]
      def retrieve_bindings(id)
        call(:get, path("#{id}/bindings/"))
      end

      # Bind a consumer to a repository for a given distributor
      #
      # @param  [String]                id              the ID of the consumer
      # @param  [String]                repo_id         the ID of the repository
      # @param  [String]                distributor_id  the ID of the distributor
      # @param  [Hash]                  optional optional parameters
      # @return [RestClient::Response]
      def bind(id, repo_id, distributor_id, optional = {})
        required = required_params(binding.send(:local_variables), binding, ['id'])
        call(:post, path("#{id}/bindings/"), :payload => { :required => required, :optional => optional })
      end

      # Unbind a consumer to a repository for a given distributor
      #
      # @param  [String]                id              the ID of the consumer
      # @param  [String]                repo_id         the ID of the repository
      # @param  [String]                distributor_id  the ID of the distributor
      # @return [RestClient::Response]
      def unbind(id, repo_id, distributor_id)
        call(:delete, path("#{id}/bindings/#{repo_id}/#{distributor_id}"))
      end

      # Install a set of units onto a consumer
      #
      # @param  [String]                id      the ID of the consumer
      # @param  [Array]                 units   array of units to install
      # @param  [Hash]                  options hash of install options
      # @return [RestClient::Response]
      def install_units(id, units, options = {})
        required = required_params(binding.send(:local_variables), binding, ['id'])
        call(:post, path("#{id}/actions/content/install/"), :payload => { :required => required })
      end

      # Update a set of units on a consumer
      #
      # @param  [String]                id      the ID of the consumer
      # @param  [Array]                 units   array of units to update
      # @param  [Hash]                  options hash of update options
      # @return [RestClient::Response]
      def update_units(id, units, options = {})
        required = required_params(binding.send(:local_variables), binding, ['id'])
        call(:post, path("#{id}/actions/content/update/"), :payload => { :required => required })
      end

      # Uninstall a set of units from a consumer
      #
      # @param  [String]                id      the ID of the consumer
      # @param  [Array]                 units   array of units to uninstall
      # @param  [Hash]                  options hash of uninstall options
      # @return [RestClient::Response]
      def uninstall_units(id, units, options = {})
        required = required_params(binding.send(:local_variables), binding, ['id'])
        call(:post, path("#{id}/actions/content/uninstall/"), :payload => { :required => required })
      end

      # (Re)Generate applicability for some set of consumers
      #
      # @param [Hash]                 options payload representing criteria
      # @return [RestClient::Response]
      def regenerate_applicability(options = {})
        call(:post, path('actions/content/regenerate_applicability/'), :payload => { :required => options})
      end

      # retrieve the applicability for some set of consumers
      #
      # @param  [Hash]                  options hash representing criteria
      # @return [RestClient::Response]
      def applicability(options = {})
        call(:post, path + 'content/applicability/', :payload => { :required => options })
      end
    end
  end
end
